//
//  RJLoginViewController.m
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 03.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJLoginViewController.h"
#import "RJAccessToken.h"

@interface RJLoginViewController () <UIWebViewDelegate>
@property (copy, nonatomic) RJLoginCompletionBlock completionBlock;
@property (weak, nonatomic) UIWebView *webView;
@end

@implementation RJLoginViewController

- (id)initWithCompletionBlock:(RJLoginCompletionBlock) completionBlock;
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
    [self.view addSubview:webView];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.title = @"Login";
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://oauth.vk.com/authorize?"
                           "client_id=4808171&"
                           "scope=932895&"
                           "redirect_uri=https://oauth.vk.com/blank.html&"
                           "display=mobile&"
                           "v=5.28&"
                           "response_type=token"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webView.delegate = self;
    [webView loadRequest:request];
    self.webView = webView;
}

- (void)dealloc {
    self.webView.delegate = nil;
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)item {
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] description] rangeOfString:@"#access_token="].location != NSNotFound) {
        RJAccessToken* token = [[RJAccessToken alloc] init];
        NSString* query = [[request URL] description];
        NSArray* array = [query componentsSeparatedByString:@"#"];
        if ([array count] > 1) {
            query = [array lastObject];
        }
        NSArray* pairs = [query componentsSeparatedByString:@"&"];
        for (NSString* pair in pairs) {
            NSArray* values = [pair componentsSeparatedByString:@"="];
            if ([values count] == 2) {
                NSString* key = [values firstObject];
                if ([key isEqualToString:@"access_token"]) {
                    token.token = [values lastObject];
                } else if ([key isEqualToString:@"expires_in"]) {
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                } else if ([key isEqualToString:@"user_id"]) {
                    token.userID = [values lastObject];
                }
            }
        }
        self.webView.delegate = nil;
        if (self.completionBlock) {
            self.completionBlock(token);
        }
        
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        
        return NO;
    }
    return YES;
}

@end

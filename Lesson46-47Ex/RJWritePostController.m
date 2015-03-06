//
//  RJWritePostController.m
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 04.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJWritePostController.h"
#import "RJServerManager.h"
#import "RJUserProfileController.h"

@interface RJWritePostController () <UITextViewDelegate>
@end

@implementation RJWritePostController


#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textView becomeFirstResponder];
    self.doneButton.enabled = 0;
    self.textView.text = @"Написать сообщение";
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    self.textView.textColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)actionDoneButtonPressed:(UIBarButtonItem *)sender {
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.textView.bounds) - 32);
    [self.view addSubview:view];
    [view startAnimating];
    
    [[RJServerManager sharedManager] postText:self.textView.text
                                       onWall:[NSString stringWithFormat:@"%ld", self.ownerID]
                                    onSuccess:^(id result) {
                                        [view stopAnimating];
                                        [self.previousController.tableView reloadData];
                                        self.previousController.needUpdateAfterPosting = YES;
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                                    onFailure:^(NSError *error, NSInteger statusCode) {
                                        NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
                                    }];
}

- (IBAction)actionCancelButtonPressed:(UIBarButtonItem *)sender {
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (!([textView.text isEqualToString:@""] || [textView.text isEqualToString:@"Написать сообщение"])) {
        self.doneButton.enabled = 1;
    } else {
        self.doneButton.enabled = 0;
    }
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Написать сообщение";
        [textView setSelectedRange:NSMakeRange(0, 0)];
        textView.textColor = [UIColor lightGrayColor];
    } else if ([[textView.text substringFromIndex:1] isEqualToString:@"Написать сообщение"] && textView.textColor == [UIColor lightGrayColor]) {
        textView.text = [textView.text substringToIndex:1];
        textView.textColor = [UIColor blackColor];
    } else {
        textView.textColor = [UIColor blackColor];
    }
}

@end

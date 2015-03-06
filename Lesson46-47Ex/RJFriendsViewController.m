//
//  RJFriendsViewController.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 25.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJFriendsViewController.h"
#import "RJServerManager.h"
#import "RJUser.h"
#import "UIImageView+AFNetworking.h"
#import "UIScrollView+InfiniteScroll.h"
#import "RJUserProfileController.h"
#import "RJFriendListCell.h"

@interface RJFriendsViewController () <UITableViewDataSource>
@property (strong, nonatomic) NSArray *friendsArray;
@property (assign, nonatomic) BOOL firstTimeAppear;
@end

NSInteger friendsBatch = 20;

@implementation RJFriendsViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendsArray = [NSArray new];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self getFriendsFromServer];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    __weak RJFriendsViewController *weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UIScrollView *scrollView) {
        [weakSelf getFriendsFromServer];
        [scrollView finishInfiniteScroll];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - API

- (void)getFriendsFromServer {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    view.center = CGPointMake(CGRectGetMidX(self.tableView.bounds), 20);
    [self.tableView addSubview:view];
    [view startAnimating];
    
    [[RJServerManager sharedManager] getFriendsForId:self.userID withCount:friendsBatch andOffset:[self.friendsArray count] onSuccess:^(NSArray *friends) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [[self mutableArrayValueForKey:@"friendsArray"] addObjectsFromArray:friends];
        NSMutableArray *newPaths = [NSMutableArray array];
        for (int i = (int)[self.friendsArray count] - (int)[friends count]; i < [self.friendsArray count]; i++) {
            [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        [view stopAnimating];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendsArray count];
}

- (RJFriendListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    RJFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[RJFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *friendInfo = [self.friendsArray objectAtIndex:indexPath.row];
    RJUser *friend = [[RJUser alloc] initWithDictionary:friendInfo];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
    NSURL *imageURL = [NSURL URLWithString:friend.imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    cell.imageView.image = nil;
    cell.onlineImageView.image = nil;
    cell.imageView.layer.cornerRadius = 21.75f;
    cell.imageView.clipsToBounds = YES;
    __weak RJFriendListCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.imageView.image = image;
                                       if (friend.online && friend.onlineMobile) {
                                           weakCell.onlineImageView.image = [UIImage imageNamed:@"online_mobile_small"];
                                       } else if (friend.online) {
                                           weakCell.onlineImageView.image = [UIImage imageNamed:@"online"];
                                       }
                                       [weakCell layoutSubviews];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"Error = %@, code = %ld", [error localizedDescription], response.statusCode);
                                   }];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *friendInfo = [self.friendsArray objectAtIndex:indexPath.row];
    RJUser *friend = [[RJUser alloc] initWithDictionary:friendInfo];
    RJUserProfileController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFriendProfileController"];
    vc.user = friend;
    [self.navigationController pushViewController:vc animated:YES];
}


@end

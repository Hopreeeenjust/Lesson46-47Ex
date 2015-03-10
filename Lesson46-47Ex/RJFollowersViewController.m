//
//  RJFollowersViewController.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 27.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJFollowersViewController.h"
#import "RJServerManager.h"
#import "RJUser.h"
#import "UIImageView+AFNetworking.h"
#import "UIScrollView+InfiniteScroll.h"
#import "RJUserProfileController.h"
#import "RJFriendListCell.h"

@interface RJFollowersViewController () <UITableViewDataSource>
@property (strong, nonatomic) NSArray *followersArray;
@property (strong, nonatomic) UIImageView *onlineStatusImageView;
@end

@implementation RJFollowersViewController

NSInteger followersBatch = 20;

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Последователи";
    self.followersArray = [NSArray new];
    
    self.onlineStatusImageView = [UIImageView new];
    
    [self getFollowersFromServer];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    __weak RJFollowersViewController *weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UIScrollView *scrollView) {
        [weakSelf getFollowersFromServer];
        [scrollView finishInfiniteScroll];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - API

- (void)getFollowersFromServer {
    [[RJServerManager sharedManager]
     getFollowersForId:self.userID
     withCount:followersBatch
     andOffset:[self.followersArray count]
     onSuccess:^(NSArray *followers) {
         [[self mutableArrayValueForKey:@"followersArray"] addObjectsFromArray:followers];;
         NSMutableArray *newPaths = [NSMutableArray array];
         for (int i = (int)[self.followersArray count] - (int)[followers count]; i < [self.followersArray count]; i++) {
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         [self.tableView beginUpdates];
         [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
         [self.tableView endUpdates];
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.followersArray count];
}

- (RJFriendListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    RJFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[RJFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *friendInfo = [self.followersArray objectAtIndex:indexPath.row];
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
    NSDictionary *followerInfo = [self.followersArray objectAtIndex:indexPath.row];
    RJUser *follower = [[RJUser alloc] initWithDictionary:followerInfo];
    RJUserProfileController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFriendProfileController"];
    vc.user = follower;
    [self.navigationController pushViewController:vc animated:YES];
}

@end

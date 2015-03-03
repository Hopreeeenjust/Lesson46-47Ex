//
//  RJGroupsViewController.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 27.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJGroupsViewController.h"
#import "RJGroup.h"
#import "RJServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "UIScrollView+InfiniteScroll.h"

@interface RJGroupsViewController () <UITableViewDataSource>
@property (strong, nonatomic) NSArray *groupsArray;
@end

NSInteger groupsBatch = 20;

@implementation RJGroupsViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Groups";

    if (!self.userID) {
        self.userID = 6054746;
    }
    self.groupsArray = [NSArray new];
    
    [self getGroupsFromServer];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    __weak RJGroupsViewController *weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UIScrollView *scrollView) {
        [weakSelf getGroupsFromServer];
        [scrollView finishInfiniteScroll];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - API

- (void)getGroupsFromServer {
    [[RJServerManager sharedManager] getGroupsForId:self.userID withCount:groupsBatch andOffset:[self.groupsArray count] onSuccess:^(NSArray *groups) {
        [[self mutableArrayValueForKey:@"groupsArray"] addObjectsFromArray:groups];;
        NSMutableArray *newPaths = [NSMutableArray array];
        for (int i = (int)[self.groupsArray count] - (int)[groups count]; i < [self.groupsArray count]; i++) {
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
    return [self.groupsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *groupInfo = [self.groupsArray objectAtIndex:indexPath.row];
    RJGroup *group = [[RJGroup alloc] initWithDictionary:groupInfo];
    cell.textLabel.text = group.name;
    NSURL *imageURL = [NSURL URLWithString:group.imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    cell.imageView.image = nil;
    cell.imageView.layer.cornerRadius = 21.75f;
    cell.imageView.clipsToBounds = YES;
    __weak UITableViewCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.imageView.image = image;
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
//    NSDictionary *friendInfo = [self.friendsArray objectAtIndex:indexPath.row];
//    RJUser *friend = [[RJUser alloc] initWithDictionary:friendInfo];
//    RJFriendProfileController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFriendProfileController"];
//    vc.userID = friend.friendID;
//    vc.title = friend.firstName;
//    [self.navigationController pushViewController:vc animated:YES];
}

@end
//
//  RJFriendProfileController.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 25.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJFriendProfileController.h"
#import "RJServerManager.h"
#import "RJUser.h"
#import "UIImageView+AFNetworking.h"
#import "RJFollowersViewController.h"
#import "RJFriendsViewController.h"
#import "RJGroupsViewController.h"
#import "UIScrollView+InfiniteScroll.h"
#import "RJWallPost.h"
#import "RJWallPostCell.h"
#import "RJGroup.h"
#import "RJPhoto.h"

@interface RJFriendProfileController () <UITableViewDataSource>
@property (strong, nonatomic) RJUser *friend;
@property (strong, nonatomic) RJUser *postOwner;
@property (strong, nonatomic) id repostOwner;
@property (strong, nonatomic) NSArray *postsArray;
@property (strong, nonatomic) NSArray *usersArray;
@property (strong, nonatomic) NSArray *groupsArray;

@end

NSInteger wallPostsBatch = 7;

@implementation RJFriendProfileController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoImageView.layer.cornerRadius = CGRectGetHeight(self.photoImageView.bounds) / 2;
    self.photoImageView.clipsToBounds = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.title = self.title;
    [self getFriendInfoFromServer];
    [self getWallPostsFromServer];
    self.followersButton.layer.cornerRadius = 5;
    self.followersButton.clipsToBounds = YES;
    self.followingButton.layer.cornerRadius = 5;
    self.followingButton.clipsToBounds = YES;
    self.groupsButton.layer.cornerRadius = 5;
    self.groupsButton.clipsToBounds = YES;
    
    self.postsArray = [NSArray new];
    self.usersArray = [NSArray new];
    self.groupsArray = [NSArray new];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    __weak RJFriendProfileController *weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UIScrollView *scrollView) {
        [weakSelf getWallPostsFromServer];
        [scrollView finishInfiniteScroll];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - API

- (void)getFriendInfoFromServer {
    [[RJServerManager sharedManager]
     getFriendInfoForId:self.userID
     onSuccess:^(NSArray *friendsInfo) {
         NSDictionary *userInfo = [friendsInfo firstObject];
         RJUser *friend = [[RJUser alloc] initWithDictionary:userInfo];
         self.friend = friend;
         [self.photoImageView setImageWithURL:[NSURL URLWithString:friend.originalImageUrl]];
         self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
         self.cityLabel.text = [self showCityAndCountry];
         if (friend.online) {
             if (friend.onlineMobile) {
                 self.statusLabel.text = @"Online (mob.)";
             } else {
                 self.statusLabel.text = @"Online";
             }
         } else {
             self.statusLabel.text = [self statusText];
         }
         if (friend.birthDate.length > 5) {    //we got full date of birth
             self.ageLabel.text = [self showAge];
         }
         UIView *view = [self.statusLabel superview];
         [view reloadInputViews];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);

     }];
}

- (void)getWallPostsFromServer {
    [[RJServerManager sharedManager]
     getWallForId:self.userID
     withCount:wallPostsBatch
     andOffset:[self.postsArray count]
     onSuccess:^(NSArray *posts, NSArray *users, NSArray *groups) {
         for (NSDictionary *postInfo in posts) {
             RJWallPost *post = [[RJWallPost alloc] initWithDictionary:postInfo];
             [[self mutableArrayValueForKey:@"postsArray"] addObject:post];
         }
         for (NSDictionary *userInfo in users) {
             RJUser *user = [[RJUser alloc] initWithDictionary:userInfo];
             [[self mutableArrayValueForKey:@"usersArray"] addObject:user];
         }
         for (NSDictionary *groupInfo in groups) {
             RJGroup *group = [[RJGroup alloc] initWithDictionary:groupInfo];
             [[self mutableArrayValueForKey:@"groupsArray"] addObject:group];
         }
         NSMutableArray *newPaths = [NSMutableArray array];
         for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         [self.tableView beginUpdates];
         [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
         [self.tableView endUpdates];
//         [self.tableView reloadData];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
}

#pragma mark - Actions

- (IBAction)actionShowUserFollowers:(UIButton *)sender {
    RJFollowersViewController *vc = [[RJFollowersViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.userID = self.userID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionShowUserGroups:(UIButton *)sender {
    RJGroupsViewController *vc = [[RJGroupsViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.userID = self.userID;
    [self.navigationController pushViewController:vc animated:YES];
//    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Authorization needed" message:@"You have to be authorized to see user's groups" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//    [ac addAction:action];
//    [self presentViewController:ac animated:YES completion:nil];
}

- (IBAction)actionShowUserFriends:(UIButton *)sender {
    RJFriendsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFriendsViewController"];
    vc.userID = self.userID;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.postsArray count];
}

- (RJWallPostCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *postIdentifier = @"Post";
    static NSString *repostIdentifier = @"Repost";
    NSString *identifier;
    RJWallPost *post = [self.postsArray objectAtIndex:indexPath.row];
    if (post.hasRepost) {
        identifier = repostIdentifier;
    } else {
        identifier = postIdentifier;
    }
    RJWallPostCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[RJWallPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    for (RJUser *user in self.usersArray) {
        if (user.userID == post.userID) {
            self.postOwner = user;
            break;
        }
    }
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.postOwner.firstName, self.postOwner.lastName];
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:[post.postDate integerValue]];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    [timeFormatter setDateFormat:@"HH:mm"];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ at %@", [dateFormatter stringFromDate:postDate], [timeFormatter stringFromDate:postDate]];
    if (post.postText) {
        
        cell.postTextLabel.text = post.postText;
    }
    NSURL *imageURL = [NSURL URLWithString:self.postOwner.imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    cell.postImageView.image = nil;
    cell.postImageView.layer.cornerRadius = CGRectGetHeight(cell.postImageView.bounds) / 2;
    cell.postImageView.clipsToBounds = YES;
    __weak RJWallPostCell *weakCell = cell;
    [cell.postImageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.postImageView.image = image;
                                       [weakCell layoutSubviews];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"Error = %@, code = %ld", [error localizedDescription], response.statusCode);
                                   }];
    cell.attachmentView.image = nil;
    if (post.attachments) {
        RJPhoto *photo = [[RJPhoto alloc] initWithDictionary:[post.attachments firstObject]];
        NSURL *photoURL = [NSURL URLWithString:photo.imageUrl];
        NSURLRequest *photoRequest = [NSURLRequest requestWithURL:photoURL];
        [cell.attachmentView setImageWithURLRequest:photoRequest
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      weakCell.attachmentView.image = image;
                                      [weakCell layoutSubviews];
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      NSLog(@"Error = %@, code = %ld", [error localizedDescription], response.statusCode);
                                  }];
    }
    cell.commentsLabel.text = [NSString stringWithFormat:@"Comments: %ld", post.comments];
    cell.commentsLabel.layer.cornerRadius = 5.f;
    cell.commentsLabel.clipsToBounds = YES;
    cell.repostsLabel.text = [NSString stringWithFormat:@"Reposts: %ld", post.reposts];
    cell.repostsLabel.layer.cornerRadius = 5.f;
    cell.repostsLabel.clipsToBounds = YES;
    cell.likesLabel.text = [NSString stringWithFormat:@"Likes: %ld", post.likes];
    cell.likesLabel.layer.cornerRadius = 5.f;
    cell.likesLabel.clipsToBounds = YES;
    
//from here code for repost cell starts
    self.repostOwner = nil;
    if (post.hasRepost) {
        for (RJUser *user in self.usersArray) {
            if (user.userID == post.repostSourceID) {
                self.repostOwner = user;
                break;
            }
        }
        if (!self.repostOwner) {
            for (RJGroup *group in self.groupsArray) {
                if (group.groupID == -post.repostSourceID) {
                    self.repostOwner = group;
                    break;
                }
            }
        }
        NSString *imageUrlString;
        if ([self.repostOwner isKindOfClass:[RJUser class]]) {
            RJUser *user = (RJUser *)self.repostOwner;
            cell.repostNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
            imageUrlString = user.imageUrl;
        } else if ([self.repostOwner isKindOfClass:[RJGroup class]]) {
            RJGroup *group = (RJGroup *)self.repostOwner;
            cell.repostNameLabel.text = group.name;
            imageUrlString = group.imageUrl;
        }
        NSDate *repostDate = [NSDate dateWithTimeIntervalSince1970:[post.repostDate integerValue]];
        cell.repostDateLabel.text = [NSString stringWithFormat:@"%@ at %@", [dateFormatter stringFromDate:repostDate], [timeFormatter stringFromDate:repostDate]];
        if (post.repostText) {
            cell.repostTextLabel.text = post.repostText;
        }
        NSURL *repostImageURL = [NSURL URLWithString:imageUrlString];
        NSURLRequest *repostRequest = [NSURLRequest requestWithURL:repostImageURL];
        cell.repostImageView.image = nil;
        cell.repostImageView.layer.cornerRadius = CGRectGetHeight(cell.repostImageView.bounds) / 2;
        cell.repostImageView.clipsToBounds = YES;
        [cell.repostImageView setImageWithURLRequest:repostRequest
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               weakCell.repostImageView.image = image;
                                               [weakCell layoutSubviews];
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               NSLog(@"Error = %@, code = %ld", [error localizedDescription], response.statusCode);
                                           }];
    }
    cell.repostAttachmentView.image = nil;
    if (post.repostAttachments) {
        RJPhoto *photo = [[RJPhoto alloc] initWithDictionary:[post.repostAttachments firstObject]];
        NSURL *photoURL = [NSURL URLWithString:[(NSArray *)photo.imageUrl firstObject]];
        NSURLRequest *photoRequest = [NSURLRequest requestWithURL:photoURL];
        [cell.repostAttachmentView setImageWithURLRequest:photoRequest
                                   placeholderImage:nil
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                weakCell.repostAttachmentView.image = image;
                                                [weakCell layoutSubviews];
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                NSLog(@"Error = %@, code = %ld", [error localizedDescription], response.statusCode);
                                            }];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 420;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Methods

- (NSString *)statusText {
    NSString *status = nil;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    [formatter setTimeZone:tz];
    NSString *date = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.friend.lastSeen]];
    NSDateFormatter *justTimeFormatter = [NSDateFormatter new];
    [justTimeFormatter setDateFormat:@"HH:mm"];
    [justTimeFormatter setTimeZone:tz];
    NSString *time = [justTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.friend.lastSeen]];
    NSInteger gap = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:self.friend.lastSeen]];
    switch (gap) {
        case 0 ... 59:
            status = [NSString stringWithFormat:@"Last seen %ld seconds ago", gap];
            break;
        case 60 ... 3599:
            status = [NSString stringWithFormat:@"Last seen %ld minutes ago", gap / 60];
            break;
        case 3600 ... (3600 * 2 - 1):
            status = [NSString stringWithFormat:@"Last seen %ld hour ago", gap / 60 / 60];
            break;
        case 3600 * 2 ... (3600 * 4 - 1):
            status = [NSString stringWithFormat:@"Last seen %ld hours ago", gap / 60 / 60];
            break;
        case 3600 * 4 ... (3600 * 24 - 1):
            status = [NSString stringWithFormat:@"Last seen today on %@", time];
            break;
        default:
            status = [NSString stringWithFormat:@"Last seen on %@", date];
            break;
    }
    return status;
}

- (NSString *)showAge {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [formatter dateFromString:self.friend.birthDate];
    NSInteger age = (NSInteger)(([[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:date]) / 60 / 60 / 24 / 365.25);
    if (age % 10 == 1) {
        return [NSString stringWithFormat:@"%ld year", age];

    } else {
        return [NSString stringWithFormat:@"%ld years", age];
    }
}

- (NSString *)showCityAndCountry {
    if (self.friend.city) {
        NSString *lastLetterInCityName = [self.friend.city substringFromIndex:self.friend.city.length - 1];
        if ([lastLetterInCityName isEqualToString:@" "]) {
            return [NSString stringWithFormat:@"%@, %@", [self.friend.city substringToIndex:self.friend.city.length - 1], self.friend.country];
        } else {
            return [NSString stringWithFormat:@"%@, %@", self.friend.city, self.friend.country];
        }
    } else {
        return nil;
    }
}

@end

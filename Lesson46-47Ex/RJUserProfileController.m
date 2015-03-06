//
//  RJFriendProfileController.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 25.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJUserProfileController.h"
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
#import "RJAccessToken.h"
#import "RJFirstCell.h"
#import "RJWritePostController.h"
#import "RJDialogsViewController.h"

@interface RJUserProfileController () <UITableViewDataSource>
@property (strong, nonatomic) RJUser *postOwner;
@property (strong, nonatomic) id repostOwner;
@property (strong, nonatomic) NSArray *postsArray;
@property (strong, nonatomic) NSArray *usersArray;
@property (strong, nonatomic) NSArray *groupsArray;
@property (strong, nonatomic) UISegmentedControl *wallDisplayControl;
@property (strong, nonatomic) UIButton *wallPostButton;
@property (strong, nonatomic) NSString *currentWallFilter;
@property (assign, nonatomic) BOOL loadMorePosts;
@end

NSInteger wallPostsBatch = 7;
static BOOL firstTimeAppear = YES;

@implementation RJUserProfileController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentWallFilter = @"all";
    
    if (!firstTimeAppear) {
        [self getUserInfoFromServer];
        [self getWallPostsFromServerWithFilter:self.currentWallFilter];
    }
    
    if (self.user && self.user.userID != [[[RJServerManager sharedManager] loggedUser] userID]) {
        self.sendMessageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.sendMessageButton setTitle:@"Личное сообщение" forState:UIControlStateNormal];
    }             //to show right title for message button
    
    self.photoImageView.layer.cornerRadius = CGRectGetHeight(self.photoImageView.bounds) / 2;
    self.photoImageView.clipsToBounds = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if (!firstTimeAppear) {
        self.navigationItem.title = self.user.firstName;
    }
    
    self.showFriendsButton.layer.cornerRadius = 5;
    self.showFriendsButton.clipsToBounds = YES;
    self.sendMessageButton.layer.cornerRadius = 5;
    self.sendMessageButton.clipsToBounds = YES;
    
    self.postsArray = [NSArray new];
    self.usersArray = [NSArray new];
    self.groupsArray = [NSArray new];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    __weak RJUserProfileController *weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UIScrollView *scrollView) {
        weakSelf.loadMorePosts = YES;
        [weakSelf getWallPostsFromServerWithFilter:weakSelf.currentWallFilter];
        weakSelf.loadMorePosts = NO;
        [scrollView finishInfiniteScroll];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.needUpdateAfterPosting) {
        [self getWallPostsFromServerWithFilter:self.currentWallFilter];
        self.needUpdateAfterPosting = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (firstTimeAppear) {
        [[RJServerManager sharedManager] authorizeUser:^(RJUser *user) {
            if (!self.user) {
                self.user = [[RJServerManager sharedManager] loggedUser];
            }
            [self getUserInfoFromServer];
            [self getWallPostsFromServerWithFilter:@"all"];
        }];
        firstTimeAppear = NO;
    }
}

#pragma mark - API

- (void)getUserInfoFromServer {
    [[RJServerManager sharedManager]
     getUserInfoForId:self.user.userID
     onSuccess:^(NSArray *userInfo) {
         NSDictionary *userInfoDict = [userInfo firstObject];
         RJUser *user = [[RJUser alloc] initWithDictionary:userInfoDict];
         self.user = user;
         if (!user.canSendMessage) {
             self.sendMessageButton.enabled = 0;
             self.sendMessageButton.alpha = 0.6f;
         } else {
             self.sendMessageButton.enabled = 1;
             self.sendMessageButton.alpha = 1.f;
         }
         [self.photoImageView setImageWithURL:[NSURL URLWithString:user.originalImageUrl]];
         self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
         self.cityLabel.text = [self showCityAndCountry];
         if (user.online) {
             if (user.onlineMobile) {
                 self.statusLabel.text = @"Online (моб.)";
             } else {
                 self.statusLabel.text = @"Online";
             }
         } else {
             self.statusLabel.text = [self statusText];
         }
         if (user.birthDate.length > 5) {    //we got full date of birth
             self.ageLabel.text = [self showAge];
         }
         UIView *view = [self.statusLabel superview];
         [self setTitleForButton:self.showFriendsButton];
         [view reloadInputViews];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);

     }];
}

- (void)getWallPostsFromServerWithFilter:(NSString *)filter {
    if (self.postsArray.count > 0 && !self.loadMorePosts) {
        [[self mutableArrayValueForKey:@"postsArray"] removeAllObjects];
        [self.tableView reloadData];
    }
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    view.center = CGPointMake(CGRectGetMidX(self.tableView.bounds), CGRectGetMidY(self.tableView.bounds) + 20);
    [self.tableView addSubview:view];
    [view startAnimating];
    
    [[RJServerManager sharedManager]
     getWallForId:self.user.userID
     withCount:wallPostsBatch
     andOffset:[self.postsArray count]
     withFilter: filter
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
         [view stopAnimating];
         [self.tableView reloadData];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
}

#pragma mark - Actions

- (void)actionControlValueChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.currentWallFilter = @"all";
    } else {
        self.currentWallFilter = @"owner";
    }
    [self getWallPostsFromServerWithFilter:self.currentWallFilter];
}

- (void)actionWallPostButtonClicked:(UIButton *)sender {
    RJWritePostController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJWritePostController"];
    vc.ownerID = self.user.userID;
    vc.previousController = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)actionShowUserFollowers:(UIButton *)sender {
    RJFollowersViewController *vc = [[RJFollowersViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.userID = self.user.userID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionShowUserGroups:(UIButton *)sender {
    RJGroupsViewController *vc = [[RJGroupsViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.userID = self.user.userID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionShowUserFriends:(UIButton *)sender {
    RJFriendsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFriendsViewController"];
    vc.userID = self.user.userID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionWriteMessage:(UIButton *)sender {
    if (self.user && self.user.userID == [[[RJServerManager sharedManager] loggedUser] userID]) {
        RJDialogsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJDialogsViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.user.canPost) {
        return [self.postsArray count] + 1;
    } else {
        return [self.postsArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *postIdentifier = @"Post";
    static NSString *repostIdentifier = @"Repost";
    static NSString *firstCellIdentifier = @"FirstCell";
    NSString *identifier;
    RJWallPost *post;
    
    if (indexPath.row == 0 && self.user.canPost) {
        RJFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:firstCellIdentifier];
        if (!cell) {
            cell = [[RJFirstCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:firstCellIdentifier];
        }
        
        self.wallDisplayControl = cell.segmentedControl;
        [self.wallDisplayControl addTarget:self action:@selector(actionControlValueChanged:) forControlEvents: UIControlEventValueChanged];
        [self setAttributesForControl:cell.segmentedControl];
        
        self.wallPostButton = cell.wallPostButton;
        [self.wallPostButton addTarget:self action:@selector(actionWallPostButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        
        return cell;
    } else {
        if ([self.postsArray count] > 0 && self.user.canPost) {
            post = [self.postsArray objectAtIndex:indexPath.row - 1];
        } else {
            post = [self.postsArray objectAtIndex:indexPath.row];
        }
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
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.user.canPost) {
        return 44;
    } else {
        return 404;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Methods

- (NSString *)statusText {
    NSString *status = nil;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    [formatter setTimeZone:tz];
    NSString *date = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.user.lastSeen]];
    NSDateFormatter *justTimeFormatter = [NSDateFormatter new];
    [justTimeFormatter setDateFormat:@"HH:mm"];
    [justTimeFormatter setTimeZone:tz];
    NSString *time = [justTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.user.lastSeen]];
    NSInteger gap = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:self.user.lastSeen]];
    switch (gap) {
        case 0 ... 59:
            status = [NSString stringWithFormat:@"%@ %ld секунд назад", self.user.gender == RJUserGenderMale ?  @"Заходил" : @"Заходила", gap];
            break;
        case 60 ... 3599:
            status = [NSString stringWithFormat:@"%@ %ld минут назад", self.user.gender == RJUserGenderMale ?  @"Заходил" : @"Заходила", gap / 60];
            break;
        case 3600 ... (3600 * 2 - 1):
            status = [NSString stringWithFormat:@"%@ %ld час назад", self.user.gender == RJUserGenderMale ?  @"Заходил" : @"Заходила", gap / 60 / 60];
            break;
        case 3600 * 2 ... (3600 * 4 - 1):
            status = [NSString stringWithFormat:@"%@ %ld часа назад", self.user.gender == RJUserGenderMale ?  @"Заходил" : @"Заходила", gap / 60 / 60];
            break;
        case 3600 * 4 ... (3600 * 24 - 1):
            status = [NSString stringWithFormat:@"%@ сегодня в %@", self.user.gender == RJUserGenderMale ?  @"Заходил" : @"Заходила", time];
            break;
        default:
            status = [NSString stringWithFormat:@"%@ %@", self.user.gender == RJUserGenderMale ?  @"Заходил" : @"Заходила", date];
            break;
    }
    return status;
}

- (NSString *)showAge {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [formatter dateFromString:self.user.birthDate];
    NSInteger age = (NSInteger)(([[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:date]) / 60 / 60 / 24 / 365.25);
    if (age % 10 == 1) {
        return [NSString stringWithFormat:@"%ld год", age];

    } else {
        return [NSString stringWithFormat:@"%ld года", age];
    }
}

- (NSString *)showCityAndCountry {
    if (self.user.city) {
        NSString *lastLetterInCityName = [self.user.city substringFromIndex:self.user.city.length - 1];
        if ([lastLetterInCityName isEqualToString:@" "]) {
            return [NSString stringWithFormat:@"%@, %@", [self.user.city substringToIndex:self.user.city.length - 1], self.user.country];
        } else {
            return [NSString stringWithFormat:@"%@, %@", self.user.city, self.user.country];
        }
    } else {
        return nil;
    }
}

- (void)setTitleForButton:(UIButton *)button {
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    switch (self.user.friendsCount % 10) {
        case 1:
            [button setTitle:[NSString stringWithFormat:@"%ld друг", self.user.friendsCount] forState:UIControlStateNormal];
            break;
        case 2 ... 4:
            [button setTitle:[NSString stringWithFormat:@"%ld друга", self.user.friendsCount] forState:UIControlStateNormal];
            break;
        default:
            [button setTitle:[NSString stringWithFormat:@"%ld друзей", self.user.friendsCount] forState:UIControlStateNormal];
            break;
    }
}

- (void)setAttributesForControl:(UISegmentedControl *)segmentedControl {
    [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
    
}

@end

//
//  RJDialogsController.m
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 04.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJDialogsViewController.h"
#import "UIScrollView+InfiniteScroll.h"
#import "RJServerManager.h"
#import "RJDialogsCell.h"
#import "RJDialog.h"
#import "RJUser.h"
#import "UIImageView+AFNetworking.h"
#import "RJChatViewController.h"

@interface RJDialogsViewController () <UITableViewDataSource>
@property (strong, nonatomic) NSArray *dialogsArray;
@property (strong, nonatomic) NSArray *usersArray;
@property (strong, nonatomic) NSArray *userIDsArray;
@property (strong, nonatomic) UIImage *loggedUserImage;
@property (strong, nonatomic) UIImage *friendImage;
@property (assign, nonatomic) BOOL loggedUserPhotoDownloaded;
@end

NSInteger dialogsBatch = 20;

@implementation RJDialogsViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loggedUserPhotoDownloaded = NO;
    
    self.dialogsArray = [NSArray new];
    self.usersArray = [NSArray new];
    self.userIDsArray = [NSArray new];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    __weak RJDialogsViewController *weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UIScrollView *scrollView) {
        [weakSelf getDialogsFromServer];
        [scrollView finishInfiniteScroll];
    }];
    
    UIRefreshControl *refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(actionRefreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self actionRefreshWall];
}

#pragma mark - API

- (void)getDialogsFromServer {
    UIActivityIndicatorView *view;
    if ([self.dialogsArray count] == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.center = CGPointMake(CGRectGetMidX(self.tableView.bounds), 20);
        [self.tableView addSubview:view];
        [view startAnimating];
    }
    
    [[RJServerManager sharedManager] getDialogsWithCount:dialogsBatch andOffset:[self.dialogsArray count] onSuccess:^(NSArray *dialogs) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        NSMutableArray *lastTenDialogsArray = [NSMutableArray new];
        for (NSDictionary *dialogDict in dialogs) {
            RJDialog *dialog = [[RJDialog alloc] initWithDictionary:dialogDict];
            [[self mutableArrayValueForKey:@"dialogsArray"] addObject:dialog];
            [lastTenDialogsArray addObject:dialog];
        }
        [[self mutableArrayValueForKey:@"userIDsArray"] removeAllObjects];
        [[self mutableArrayValueForKey:@"userIDsArray"] addObjectsFromArray:[lastTenDialogsArray valueForKeyPath:@"@unionOfObjects.userID"]];

        [[RJServerManager sharedManager] getUser:self.userIDsArray
                                       onSuccess:^(NSArray *users) {
                                           [[self mutableArrayValueForKey:@"usersArray"] addObjectsFromArray:users];
                                           [self.tableView reloadData];
                                           [view stopAnimating];
                                       } onFailure:^(NSError *error, NSInteger statusCode) {
                                           NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
                                       }];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dialogsArray count];
}

- (RJDialogsCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"LastMineMessage";
    static NSString *friendsIdentifier = @"LastFriendsMessage";
    
    RJUser *user;
    RJDialog *dialog = [self.dialogsArray objectAtIndex:indexPath.row];
    if ([self.usersArray count] > 0) {
        user = [self.usersArray objectAtIndex:indexPath.row];
    }
    
    NSString *identifier;
    if (dialog.lastMessageIsMine) {
        identifier = myIdentifier;
    } else {
        identifier = friendsIdentifier;
    }
    
    RJDialogsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.myImageView.image = nil;
    cell.myImageView.layer.cornerRadius = CGRectGetHeight(cell.myImageView.bounds) / 2;
    cell.myImageView.clipsToBounds = YES;
    __weak RJDialogsCell *weakCell = cell;
    if (dialog.lastMessageIsMine) {
        if (!self.loggedUserPhotoDownloaded) {
            NSURL *imageURL = [NSURL URLWithString:[[[RJServerManager sharedManager] loggedUser] imageUrl]];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
            [cell.myImageView setImageWithURLRequest:request
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 weakCell.myImageView.image = image;
                                                 self.loggedUserImage = image;
                                                 [weakCell layoutSubviews];
                                                 self.loggedUserPhotoDownloaded = YES;
                                             }
                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 NSLog(@"Error = %@, code = %ld", [error localizedDescription], response.statusCode);
                                             }];
        } else {
            cell.myImageView.image = self.loggedUserImage;
        }
    }
 
    if (dialog.text) {
        cell.messageTextLabel.text = dialog.text;
    }
    if (dialog.messageState == RJMessageStateUnread && dialog.lastMessageIsMine) {
        cell.messageTextLabel.backgroundColor = [UIColor colorWithRed:0.906f green:0.95f blue:0.996f alpha:1];
    } else if (dialog.messageState == RJMessageStateUnread) {
        cell.backgroundColor = [UIColor colorWithRed:0.906f green:0.95f blue:0.996f alpha:1];
    } else {
        cell.backgroundColor = [UIColor clearColor];
        cell.messageTextLabel.backgroundColor = [UIColor clearColor];
    }
    [cell.messageTextLabel sizeToFit];
    
    if (dialog.lastMessageInterval) {
        cell.dateLabel.text = [self stringDateFromTimeInterval:dialog.lastMessageInterval];
    }
    
    if (user) {
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        [cell.nameLabel sizeToFit];
    }
    
    [cell.onlineImageView removeFromSuperview];
    CGFloat imageViewSize = 44.f;
    CGFloat horizontalOffset = 5.f;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cell.nameLabel.frame) - imageViewSize / 2 + horizontalOffset, CGRectGetMinY(cell.nameLabel.frame) + CGRectGetHeight(cell.nameLabel.bounds) / 2 - imageViewSize / 2, imageViewSize, imageViewSize)];
    if (user.online && user.onlineMobile) {
        imageView.image = [UIImage imageNamed:@"online_mobile_small"];
    } else if (user.online) {
        imageView.image = [UIImage imageNamed:@"online"];
    }
    cell.onlineImageView = imageView;
    [cell.contentView addSubview:cell.onlineImageView];
    
    NSURL *imageURL = [NSURL URLWithString:user.imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    cell.friendsImageView.image = nil;
    cell.friendsImageView.layer.cornerRadius = CGRectGetHeight(cell.friendsImageView.bounds) / 2;
    cell.friendsImageView.clipsToBounds = YES;
    [cell.friendsImageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.friendsImageView.image = image;
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

    RJUser *user = [self.usersArray objectAtIndex:indexPath.row];
    
    RJDialogsCell *cell = (RJDialogsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    RJChatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJChatViewController"];
    vc.user = user;
    vc.userImage = [cell.friendsImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions

- (void)actionRefreshWall {
    [[RJServerManager sharedManager]
     getDialogsWithCount:MAX(dialogsBatch, [self.dialogsArray count])
     andOffset:0
     onSuccess:^(NSArray *dialogs) {
        [[self mutableArrayValueForKey:@"dialogsArray"] removeAllObjects];
        for (NSDictionary *dialogDict in dialogs) {
            RJDialog *dialog = [[RJDialog alloc] initWithDictionary:dialogDict];
            [[self mutableArrayValueForKey:@"dialogsArray"] addObject:dialog];
        }
        [[self mutableArrayValueForKey:@"userIDsArray"] removeAllObjects];
        [[self mutableArrayValueForKey:@"userIDsArray"] addObjectsFromArray:[self.dialogsArray valueForKeyPath:@"@unionOfObjects.userID"]];
        
        [[self mutableArrayValueForKey:@"usersArray"] removeAllObjects];
        [[RJServerManager sharedManager] getUser:self.userIDsArray
                                       onSuccess:^(NSArray *users) {
                                           [[self mutableArrayValueForKey:@"usersArray"] addObjectsFromArray:users];
                                           [self.tableView reloadData];
                                           [self.refreshControl endRefreshing];
                                       } onFailure:^(NSError *error, NSInteger statusCode) {
                                           NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
                                       }];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
    }];
}

#pragma mark - Methods

- (NSString *)stringDateFromTimeInterval:(NSTimeInterval)timeInterval {
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *dateString = nil;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    [formatter setTimeZone:tz];
    NSString *dateS = [formatter stringFromDate:messageDate];
    
    NSDateFormatter *justTimeFormatter = [NSDateFormatter new];
    [justTimeFormatter setDateFormat:@"HH:mm"];
    [justTimeFormatter setTimeZone:tz];
    NSString *time = [justTimeFormatter stringFromDate:messageDate];
    
    NSDateFormatter *justDayOfWeekFormatter = [NSDateFormatter new];
    [justDayOfWeekFormatter setDateFormat:@"EEE"];
    [justDayOfWeekFormatter setTimeZone:tz];
    [justDayOfWeekFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"RU"]];
    NSString *dayOfWeek = [justDayOfWeekFormatter stringFromDate:messageDate];
    
    NSDateFormatter *justYearFormatter = [NSDateFormatter new];
    [justYearFormatter setDateFormat:@"yyyy"];
    NSString *messageYear = [justYearFormatter stringFromDate:messageDate];
    
    NSDateFormatter *dateAndMonthFormatter = [NSDateFormatter new];
    [dateAndMonthFormatter setDateFormat:@"dd MMM"];
    [dateAndMonthFormatter setTimeZone:tz];
    [dateAndMonthFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"RU"]];
    NSString *dateAndMonth = [dateAndMonthFormatter stringFromDate:messageDate];
    
    NSDate *currentDate = [NSDate date];
    NSDate *aWeekAgo  = [currentDate dateByAddingTimeInterval: -604800.0];
    NSDate *yesterday  = [currentDate dateByAddingTimeInterval: -86400.0];
    if ([[formatter stringFromDate:currentDate] isEqualToString:dateS]) {
        dateString = time;
    } else if ([[formatter stringFromDate:yesterday] isEqualToString:dateS]) {
        dateString = @"вчера";
    } else if ([messageDate compare:aWeekAgo] == NSOrderedDescending){
        dateString = dayOfWeek;
    } else if ([messageYear isEqualToString:[justYearFormatter stringFromDate:currentDate]]) {
        dateString = dateAndMonth;
    } else {
        dateString = dateS;
    }
    return dateString;
}

@end

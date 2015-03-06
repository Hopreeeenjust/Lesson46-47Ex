//
//  RJChatViewController.m
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 06.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJChatViewController.h"
#import "RJMessageCell.h"
#import "RJUser.h"
#import "RJServerManager.h"

@interface RJChatViewController () <UITableViewDataSource>
@property (strong, nonatomic) NSArray *messagesArray;
//@property (strong, nonatomic) NSArray *usersArray;
//@property (strong, nonatomic) NSArray *userIDsArray;
//@property (strong, nonatomic) UIImage *loggedUserImage;
//@property (assign, nonatomic) BOOL loggedUserPhotoDownloaded;
@end

NSInteger messagesBatch = 20;

@implementation RJChatViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.layer.cornerRadius = 5.f;
    self.textView.clipsToBounds = YES;
    self.textView.text = @"Написать сообщение";
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    self.textView.textColor = [UIColor lightGrayColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.userButton setImage:self.userImage forState:UIControlStateNormal];
    self.userButton.imageView.layer.cornerRadius = CGRectGetWidth(self.userButton.bounds) / 2;
    self.userButton.imageView.clipsToBounds = YES;
    
    [self getSetNavigationBarTitle];
    
    self.messagesArray = [NSArray new];

    UIRefreshControl *refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(refreshMessages) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagesArray count];
}

- (RJMessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *inboxIdentifier = @"Inbox";
    static NSString *outboxIdentifier = @"Outbox";
    
//    RJUser *user;
//    RJDialog *dialog = [self.dialogsArray objectAtIndex:indexPath.row];
//    if ([self.usersArray count] > 0) {
//        user = [self.usersArray objectAtIndex:indexPath.row];
//    }
    
//    NSString *identifier;
//    if (mess.lastMessageIsMine) {
//        identifier = myIdentifier;
//    } else {
//        identifier = friendsIdentifier;
//    }
    
    RJMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:inboxIdentifier];
    if (!cell) {
        cell = [[RJMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inboxIdentifier];
    }
    
//    cell.myImageView.image = nil;
//    cell.myImageView.layer.cornerRadius = CGRectGetHeight(cell.myImageView.bounds) / 2;
//    cell.myImageView.clipsToBounds = YES;
//    __weak RJDialogsCell *weakCell = cell;
//    if (dialog.lastMessageIsMine) {
//        if (!self.loggedUserPhotoDownloaded) {
//            NSURL *imageURL = [NSURL URLWithString:[[[RJServerManager sharedManager] loggedUser] imageUrl]];
//            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
//            [cell.myImageView setImageWithURLRequest:request
//                                    placeholderImage:nil
//                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                 weakCell.myImageView.image = image;
//                                                 self.loggedUserImage = image;
//                                                 [weakCell layoutSubviews];
//                                                 self.loggedUserPhotoDownloaded = YES;
//                                             }
//                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                 NSLog(@"Error = %@, code = %ld", [error localizedDescription], response.statusCode);
//                                             }];
//        } else {
//            cell.myImageView.image = self.loggedUserImage;
//        }
//    }
//    
//    if (dialog.text) {
//        cell.messageTextLabel.text = dialog.text;
//    }
//    if (dialog.messageState == RJMessageStateUnread && dialog.lastMessageIsMine) {
//        cell.messageTextLabel.backgroundColor = [UIColor colorWithRed:0.906f green:0.95f blue:0.996f alpha:1];
//    } else if (dialog.messageState == RJMessageStateUnread) {
//        cell.backgroundColor = [UIColor colorWithRed:0.906f green:0.95f blue:0.996f alpha:1];
//    } else {
//        cell.backgroundColor = [UIColor clearColor];
//        cell.messageTextLabel.backgroundColor = [UIColor clearColor];
//    }
//    [cell.messageTextLabel sizeToFit];
//    
//    if (dialog.lastMessageInterval) {
//        cell.dateLabel.text = [self stringDateFromTimeInterval:dialog.lastMessageInterval];
//    }
//    
//    if (user) {
//        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
//        [cell.nameLabel sizeToFit];
//    }
//    
//    [cell.onlineImageView removeFromSuperview];
//    CGFloat imageViewSize = 44.f;
//    CGFloat horizontalOffset = 5.f;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cell.nameLabel.frame) - imageViewSize / 2 + horizontalOffset, CGRectGetMinY(cell.nameLabel.frame) + CGRectGetHeight(cell.nameLabel.bounds) / 2 - imageViewSize / 2, imageViewSize, imageViewSize)];
//    if (user.online && user.onlineMobile) {
//        imageView.image = [UIImage imageNamed:@"online_mobile_small"];
//    } else if (user.online) {
//        imageView.image = [UIImage imageNamed:@"online"];
//    }
//    cell.onlineImageView = imageView;
//    [cell.contentView addSubview:cell.onlineImageView];
//    
//    NSURL *imageURL = [NSURL URLWithString:user.imageUrl];
//    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
//    cell.friendsImageView.image = nil;
//    cell.friendsImageView.layer.cornerRadius = CGRectGetHeight(cell.friendsImageView.bounds) / 2;
//    cell.friendsImageView.clipsToBounds = YES;
//    [cell.friendsImageView setImageWithURLRequest:request
//                                 placeholderImage:nil
//                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                              weakCell.friendsImageView.image = image;
//                                              [weakCell layoutSubviews];
//                                          }
//                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                              NSLog(@"Error = %@, code = %ld", [error localizedDescription], response.statusCode);
//                                          }];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (void) refreshMessages {
//    [[RJServerManager sharedManager]
//     getGroupWall:@"58860049"
//     withOffset:0
//     count:MAX(postsInRequest, [self.postsArray count])
//     onSuccess:^(NSArray *posts) {
//         [self.postsArray removeAllObjects];
//         [self.postsArray addObjectsFromArray:posts];
//         [self.tableView reloadData];
//         [self.refreshControl endRefreshing];
//     }
//     onFailure:^(NSError *error, NSInteger statusCode) {
//         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
//     }];
}

#pragma mark - API

- (void)getSetNavigationBarTitle {
    [[RJServerManager sharedManager]
     getUserInfoForId:self.user.userID
     onSuccess:^(NSArray *userInfo) {
         NSDictionary *userInfoDict = [userInfo firstObject];
         RJUser *user = [[RJUser alloc] initWithDictionary:userInfoDict];
         self.user = user;
         NSString *name = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];\
         NSString *onlineStatus;
         if (user.online) {
             if (user.onlineMobile) {
                 onlineStatus = @"Online (моб.)";
             } else {
                 onlineStatus = @"Online";
             }
         } else {
             onlineStatus = [self statusText];
         }
         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40)];
         label.backgroundColor = [UIColor clearColor];
         label.numberOfLines = 2;
         label.font = [UIFont boldSystemFontOfSize:15.f];
         label.textAlignment = NSTextAlignmentCenter;
         label.textColor = [UIColor whiteColor];
         NSRange range = NSMakeRange(name.length + 1, onlineStatus.length); //+1 is for \n symbol
         NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", name, onlineStatus]];
         [string addAttributes:
                     @{NSFontAttributeName:[UIFont systemFontOfSize:11.f],
                       NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.7f]}
                         range:range];
         label.attributedText = string;
         self.navigationItem.titleView = label;
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
         
     }];
}

#pragma mark - Methods
//
//- (NSString *)stringDateFromTimeInterval:(NSTimeInterval)timeInterval {
//    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
//    NSString *dateString = nil;
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    [formatter setDateFormat:@"dd.MM.yyyy"];
//    NSTimeZone *tz = [NSTimeZone localTimeZone];
//    [formatter setTimeZone:tz];
//    NSString *dateS = [formatter stringFromDate:messageDate];
//    
//    NSDateFormatter *justTimeFormatter = [NSDateFormatter new];
//    [justTimeFormatter setDateFormat:@"HH:mm"];
//    [justTimeFormatter setTimeZone:tz];
//    NSString *time = [justTimeFormatter stringFromDate:messageDate];
//    
//    NSDateFormatter *justDayOfWeekFormatter = [NSDateFormatter new];
//    [justDayOfWeekFormatter setDateFormat:@"EEE"];
//    [justDayOfWeekFormatter setTimeZone:tz];
//    [justDayOfWeekFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"RU"]];
//    NSString *dayOfWeek = [justDayOfWeekFormatter stringFromDate:messageDate];
//    
//    NSDateFormatter *justYearFormatter = [NSDateFormatter new];
//    [justYearFormatter setDateFormat:@"yyyy"];
//    NSString *messageYear = [justYearFormatter stringFromDate:messageDate];
//    
//    NSDateFormatter *dateAndMonthFormatter = [NSDateFormatter new];
//    [dateAndMonthFormatter setDateFormat:@"dd MMM"];
//    [dateAndMonthFormatter setTimeZone:tz];
//    [dateAndMonthFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"RU"]];
//    NSString *dateAndMonth = [dateAndMonthFormatter stringFromDate:messageDate];
//    
//    NSDate *currentDate = [NSDate date];
//    NSDate *aWeekAgo  = [currentDate dateByAddingTimeInterval: -604800.0];
//    NSDate *yesterday  = [currentDate dateByAddingTimeInterval: -86400.0];
//    if ([[formatter stringFromDate:currentDate] isEqualToString:dateS]) {
//        dateString = time;
//    } else if ([[formatter stringFromDate:yesterday] isEqualToString:dateS]) {
//        dateString = @"вчера";
//    } else if ([messageDate compare:aWeekAgo] == NSOrderedDescending){
//        dateString = dayOfWeek;
//    } else if ([messageYear isEqualToString:[justYearFormatter stringFromDate:currentDate]]) {
//        dateString = dateAndMonth;
//    } else {
//        dateString = dateS;
//    }
//    return dateString;
//}

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
            status = [NSString stringWithFormat:@"%@ %ld секунд назад", self.user.gender == RJUserGenderMale ?  @"заходил" : @"заходила", gap];
            break;
        case 60 ... 3599:
            status = [NSString stringWithFormat:@"%@ %ld минут назад", self.user.gender == RJUserGenderMale ?  @"заходил" : @"заходила", gap / 60];
            break;
        case 3600 ... (3600 * 2 - 1):
            status = [NSString stringWithFormat:@"%@ %ld час назад", self.user.gender == RJUserGenderMale ?  @"заходил" : @"заходила", gap / 60 / 60];
            break;
        case 3600 * 2 ... (3600 * 4 - 1):
            status = [NSString stringWithFormat:@"%@ %ld часа назад", self.user.gender == RJUserGenderMale ?  @"заходил" : @"заходила", gap / 60 / 60];
            break;
        case 3600 * 4 ... (3600 * 24 - 1):
            status = [NSString stringWithFormat:@"%@ сегодня в %@", self.user.gender == RJUserGenderMale ?  @"заходил" : @"заходила", time];
            break;
        default:
            status = [NSString stringWithFormat:@"%@ %@", self.user.gender == RJUserGenderMale ?  @"заходил" : @"заходила", date];
            break;
    }
    return status;
}

@end

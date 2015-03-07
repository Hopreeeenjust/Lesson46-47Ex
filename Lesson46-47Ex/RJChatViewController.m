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
#import "RJMessage.h"
#import "RJUserProfileController.h"
#import "RJMessageLabel.h"

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
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.userButton setImage:self.userImage forState:UIControlStateNormal];
    self.userButton.imageView.layer.cornerRadius = CGRectGetWidth(self.userButton.bounds) / 2;
    self.userButton.imageView.clipsToBounds = YES;
    
    [self setNavigationBarTitle];
    
    self.messagesArray = [NSArray new];
    
    [self getMessageFromServer];

    UIRefreshControl *refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(refreshMessages) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.tableView numberOfRowsInSection:0] > 0) {
        [self performSelector:@selector(goToBottom) withObject:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagesArray count];
}

- (RJMessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *inboxIdentifier = @"Inbox";
    static NSString *outboxIdentifier = @"Outbox";
    
    NSString *identifier;
    
    RJMessage *message = [self.messagesArray objectAtIndex:indexPath.row];
    
    if (message.messageIsMine) {
        identifier = outboxIdentifier;
    } else {
        identifier = inboxIdentifier;
    }
    
    RJMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    cell.messageTextLabel.text = message.text;
    cell.messageTextLabel.layer.cornerRadius = 7.f;
    cell.messageTextLabel.clipsToBounds = YES;
    cell.messageTextLabel.numberOfLines = 0;
    cell.messageTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.timeLabel.text = [self stringTimeFromTimeInterval:message.messageInterval];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (IBAction)actionShowUsersProfile:(id)sender {
    RJUserProfileController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFriendProfileController"];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

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

- (void)setNavigationBarTitle {
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
                 onlineStatus = @"online (моб.)";
             } else {
                 onlineStatus = @"online";
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

- (void)getMessageFromServer {
    UIActivityIndicatorView *view;
    if ([self.messagesArray count] == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.center = CGPointMake(CGRectGetMidX(self.tableView.bounds), 20);
        [self.tableView addSubview:view];
        [view startAnimating];
    }
    
    [[RJServerManager sharedManager]
     getMessageHistoryWithFriendId:self.user.userID
     withCount:messagesBatch
     andOffset:[self.messagesArray count]
     onSuccess:^(NSArray *messages, NSNumber *totalCount) {
         for (NSDictionary *messageInfo in messages) {
             RJMessage *message = [[RJMessage alloc] initWithDictionary:messageInfo];
             [[self mutableArrayValueForKey:@"messagesArray"] addObject:message];
         }
         self.messagesArray = [[self.messagesArray reverseObjectEnumerator] allObjects];
         [self.tableView reloadData];
         [view stopAnimating];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
}

#pragma mark - Methods

- (NSString *)stringTimeFromTimeInterval:(NSTimeInterval)timeInterval {
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSDateFormatter *justTimeFormatter = [NSDateFormatter new];
    [justTimeFormatter setDateFormat:@"HH:mm"];
    [justTimeFormatter setTimeZone:tz];
    NSString *time = [justTimeFormatter stringFromDate:messageDate];

    return time;
}

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

-(void)goToBottom {
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(NSIndexPath *)lastIndexPath {
    NSInteger lastSectionIndex = MAX(0, [self.tableView numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.tableView numberOfRowsInSection:lastSectionIndex] - 1);
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}


@end

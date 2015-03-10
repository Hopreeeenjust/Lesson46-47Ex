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
#import "RJMessageSection.h"
#import "UIScrollView+InfiniteScroll.h"

@interface RJChatViewController () <UITableViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) NSArray *messagesArray;
@property (strong, nonatomic) NSArray *messageSectionsArray;
@property (strong, nonatomic) RJMessageSection *messageSection;
@property (strong, nonatomic) NSArray *unreadMessages;
@property (assign, nonatomic) BOOL firstLoad;
@property (strong, nonatomic) UIRefreshControl *refresh;
@end

NSInteger messagesBatch = 70;

@implementation RJChatViewController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.firstLoad = YES;
    
    self.unreadMessages = [NSArray new];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.userButton setImage:self.userImage forState:UIControlStateNormal];
    self.userButton.imageView.layer.cornerRadius = CGRectGetWidth(self.userButton.bounds) / 2;
    self.userButton.imageView.clipsToBounds = YES;
    
    [self setNavigationBarTitle];
    
    self.messagesArray = [NSArray new];
    self.messageSectionsArray = [NSArray new];
    
    self.sendMessageButton.enabled = 0;
    
    [self getMessageFromServer];

    UIRefreshControl *refresh = [UIRefreshControl new];
    [refresh addTarget:self action:@selector(actionGetMoreMessages) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    self.refresh = refresh;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(actionKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(actionKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    __weak RJChatViewController *weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UIScrollView *scrollView) {
        [weakSelf actionUpdateMessages];
        [scrollView finishInfiniteScroll];
    }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.messageSectionsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.messageSectionsArray objectAtIndex:section] messages] count];
}

- (RJMessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self configureBasicCellAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    RJMessageSection *messageSection = [self.messagesArray objectAtIndex:section];
    RJMessage *message = [messageSection.messages firstObject];
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:message.messageInterval];
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    [formatter setTimeZone:tz];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"RU"]];
    [formatter setDateFormat:@"dd MMMM"];
    return [formatter stringFromDate:messageDate];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 14)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width, 12)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor lightGrayColor]];
    
    RJMessageSection *messageSection = [self.messageSectionsArray objectAtIndex:section];
    RJMessage *message = [messageSection.messages firstObject];
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:message.messageInterval];
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    [formatter setTimeZone:tz];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"RU"]];
    [formatter setDateFormat:@"dd MMMM"];
    NSString *string = [formatter stringFromDate:messageDate];
    if ([string hasPrefix:@"0"]) {
        string = [string substringFromIndex:1];
    }
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:234/255.0 green:240/255.0 blue:249/255.0 alpha:1.0]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 14;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RJMessageCell *cell = [self configureBasicCellAtIndexPath:indexPath];

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGSize maximumSize = CGSizeMake(320.0, UILayoutFittingCompressedSize.height);
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:maximumSize].height;
    return height;
}


#pragma mark - Actions

- (IBAction)actionShowUsersProfile:(id)sender {
    RJUserProfileController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFriendProfileController"];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionGetMoreMessages {
    [self getMessageFromServer];
}

- (void)actionKeyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

- (void)actionKeyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (IBAction)actionTextFieldDidChange:(UITextField *)sender {
    while ([sender.text hasPrefix:@" "]) {
        sender.text = [sender.text substringFromIndex:1];
    }
    if (sender.text.length == 0) {
        self.sendMessageButton.enabled = 0;
    } else {
        self.sendMessageButton.enabled = 1;
    }
}

- (void)actionDismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)actionSendButtonPushed:(UIButton *)sender {
    [[RJServerManager sharedManager]
     sendMessage:self.textField.text
     toUserWithID:self.user.userID
     onSuccess:^(id result) {
         RJMessage *message = [RJMessage new];
         message.text = self.textField.text;
         message.messageIsMine = YES;
         message.messageInterval = [[NSDate date] timeIntervalSince1970];
         message.messageState = RJMessageStateUnread;
         
         RJMessageSection *lastMessageSection = [self.messageSectionsArray lastObject];
         RJMessage *lastMessage = [lastMessageSection.messages lastObject];
         
         NSDateFormatter *formatter = [NSDateFormatter new];
         [formatter setDateFormat:@"dd.MM.yyyy"];
         NSDate *messageDate = [NSDate date];
         NSDate *lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastMessage.messageInterval];
         if ([[formatter stringFromDate:messageDate] isEqualToString:[formatter stringFromDate:lastMessageDate]]) {
             [[lastMessageSection mutableArrayValueForKey:@"messages"] addObject:message];
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[lastMessageSection.messages count] - 1 inSection:[self.messageSectionsArray count] - 1];
             [self.tableView beginUpdates];
             [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
             [self.tableView endUpdates];
             [self.tableView reloadData];
             [self goToBottom];
         } else {
             RJMessageSection *newSection = [RJMessageSection new];
             newSection.messages = [NSArray new];
             [[newSection mutableArrayValueForKey:@"messages"] addObject:message];
             [[self mutableArrayValueForKey:@"messageSectionsArray"] addObject:newSection];
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self.messageSectionsArray count] -1];
             [self.tableView beginUpdates];
             [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
             [self.tableView endUpdates];
             [self.tableView reloadData];
             [self goToBottom];
         }
         self.textField.text = @"";
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
}

- (void)actionUpdateMessages {
    [[RJServerManager sharedManager]
     getMessageHistoryWithFriendId:self.user.userID
     withCount:MAX(messagesBatch, [self.messagesArray count])
     andOffset:0
     onSuccess:^(NSArray *messages, NSNumber *totalCount) {
         [[self mutableArrayValueForKey:@"messagesArray"] removeAllObjects];
         for (NSDictionary *messageInfo in messages) {
             RJMessage *message = [[RJMessage alloc] initWithDictionary:messageInfo];
             [[self mutableArrayValueForKey:@"messagesArray"] addObject:message];
         }
         [[self mutableArrayValueForKey:@"messageSectionsArray"] removeAllObjects];
         self.messageSectionsArray = [self dateSectionsArrayForMessages];
         [self findAndMarkMessagesAsRead];
         [self.tableView reloadData];
         [self goToBottom];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
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
         self.messageSectionsArray = [self dateSectionsArrayForMessages];
         [self.tableView reloadData];
         [self goToBottom];
         if (self.firstLoad) {
             self.firstLoad = NO;
         }
         [view stopAnimating];
         if ([self.refresh isRefreshing]) {
             [self.refresh endRefreshing];

         }
         [self findAndMarkMessagesAsRead];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"Error = %@, code = %ld", [error localizedDescription], statusCode);
     }];
}

- (void)markMessagesAsRead {
    [[RJServerManager sharedManager]
     markAllMessagesAsRead:[self unreadMessageIDsStringFromArray:self.unreadMessages]
     onSuccess:^(id result) {
         [self.tableView reloadData];
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

- (void)goToBottom {
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (NSIndexPath *)lastIndexPath {
    if (self.firstLoad) {
        NSInteger lastSectionIndex = MAX(0, [self.tableView numberOfSections] - 1);
        NSInteger lastRowIndex = MAX(0, [self.tableView numberOfRowsInSection:lastSectionIndex] - 1);
        return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
    } else {
        NSArray *array = [self.tableView indexPathsForVisibleRows];
        NSIndexPath *lastVisiblePath = [array lastObject];
        return lastVisiblePath;
    }
}

- (NSArray *)dateSectionsArrayForMessages {
    self.messageSection = nil;
    NSMutableArray *tempArray = [NSMutableArray array];
    NSDate *lastDate = nil;
    NSDateFormatter *formatter = [NSDateFormatter new];
    if ([self.messageSectionsArray count] > 0) {
        [[self mutableArrayValueForKey:@"messageSectionsArray"] removeObjectAtIndex:0];
    }
    [formatter setDateFormat:@"dd.MM.yyyy"];
    for (RJMessage *message in self.messagesArray) {
        NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:message.messageInterval];
        if ([[formatter stringFromDate:messageDate] isEqualToString:[formatter stringFromDate:lastDate]]) {
            [[self.messageSection mutableArrayValueForKey:@"messages"] insertObject:message atIndex:0];
        } else {
            if ([self.messageSection.messages count] > 0) {
                [tempArray insertObject:self.messageSection atIndex:0];
            }
            RJMessageSection *section = [RJMessageSection new];
            section.messages = [NSArray new];
            self.messageSection = section;
            [[section mutableArrayValueForKey:@"messages"] insertObject:message atIndex:0];
            lastDate = messageDate;
        }
    }
    [tempArray insertObject:self.messageSection atIndex:0];
    return tempArray;
}

- (NSArray *)unreadMessagesArrayFromMessagesInArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (RJMessage *message in array) {
        if (!message.messageIsMine && message.messageState == RJMessageStateUnread) {
            [tempArray addObject:[NSNumber numberWithInteger:message.messageID]];
            message.messageState = RJMessageStateRead;
        }
    }
    return tempArray;
}

- (NSString *)unreadMessageIDsStringFromArray:(NSArray *)array {
    NSMutableString *resultString = [NSMutableString string];
    for (NSNumber *messageID in array) {
        if ([messageID isEqual:[array lastObject]]) {
            [resultString appendFormat:@"%@", messageID];
        } else {
            [resultString appendFormat:@"%@, ", messageID];
        }
    }
    return resultString;
}

- (RJMessageCell *)configureBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *inboxIdentifier = @"Inbox";
    static NSString *outboxIdentifier = @"Outbox";
    
    NSString *identifier;
    
    RJMessage *message = [[[self.messageSectionsArray objectAtIndex:indexPath.section] messages] objectAtIndex:indexPath.row];
    
    if (message.messageIsMine) {
        identifier = outboxIdentifier;
    } else {
        identifier = inboxIdentifier;
    }
    
    RJMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.messageView.layer.cornerRadius = 10.f;
    cell.messageView.clipsToBounds = YES;
    if ([message.text isEqualToString:@""]) {
        cell.messageTextLabel.text = @" ";
    } else {
        cell.messageTextLabel.text = message.text;
    }
    cell.messageTextLabel.numberOfLines = 0;
    cell.messageTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.timeLabel.text = [self stringTimeFromTimeInterval:message.messageInterval];
    
    if (message.messageState == RJMessageStateUnread) {
        cell.backgroundColor = [UIColor colorWithRed:151/255.0 green:200/255.0 blue:255/255.0 alpha:0.4];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (void)findAndMarkMessagesAsRead {
    [[self mutableArrayValueForKey:@"unreadMessages"] removeAllObjects];
    self.unreadMessages = [self unreadMessagesArrayFromMessagesInArray:self.messagesArray];
    if ([self.unreadMessages count] > 0) {
        [self markMessagesAsRead];
    }
}
@end

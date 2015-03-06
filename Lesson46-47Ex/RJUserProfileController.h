//
//  RJFriendProfileController.h
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 25.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJUser;

@interface RJUserProfileController : UITableViewController
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *showFriendsButton;

@property (strong, nonatomic) RJUser *user;
@property (assign, nonatomic) BOOL needUpdateAfterPosting;

- (IBAction)actionShowUserFollowers:(UIButton *)sender;
- (IBAction)actionShowUserFriends:(UIButton *)sender;
- (IBAction)actionShowUserGroups:(UIButton *)sender;
@end

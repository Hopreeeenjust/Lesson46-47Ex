//
//  RJFriendProfileController.h
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 25.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJFriendProfileController : UITableViewController
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIButton *groupsButton;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;

@property (assign, nonatomic) NSInteger userID;
@property (strong, nonatomic) NSString *title;

- (IBAction)actionShowUserFollowers:(UIButton *)sender;
- (IBAction)actionShowUserFriends:(UIButton *)sender;
- (IBAction)actionShowUserGroups:(UIButton *)sender;
@end

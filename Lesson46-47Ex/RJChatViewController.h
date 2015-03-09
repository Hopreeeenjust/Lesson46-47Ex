//
//  RJChatViewController.h
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 06.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJUser;

@interface RJChatViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;

@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) RJUser *user;

- (IBAction)actionTextFieldDidChange:(UITextField *)sender;
- (IBAction)actionSendButtonPushed:(UIButton *)sender;
@end

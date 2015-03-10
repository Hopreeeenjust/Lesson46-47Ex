//
//  RJUserDetailInfoController.h
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 10.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJUser;

@interface RJUserDetailInfoController : UITableViewController
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *onlineSstatus;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) RJUser *user;
@end

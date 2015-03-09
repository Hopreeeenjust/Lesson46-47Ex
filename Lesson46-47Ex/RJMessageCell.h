//
//  RJMessageCell.h
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 06.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJMessageLabel;

@interface RJMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet RJMessageLabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@end

//
//  RJWallPostCell.h
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 27.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJWallPostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *repostImageView;
@property (weak, nonatomic) IBOutlet UILabel *repostTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attachmentView;
@property (weak, nonatomic) IBOutlet UIImageView *repostAttachmentView;
@end

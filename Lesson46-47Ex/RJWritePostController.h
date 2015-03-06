//
//  RJWritePostController.h
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 04.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJUserProfileController;

@interface RJWritePostController : UIViewController
@property (assign, nonatomic) NSInteger ownerID;
@property (strong, nonatomic) RJUserProfileController *previousController;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)actionDoneButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)actionCancelButtonPressed:(UIBarButtonItem *)sender;
@end

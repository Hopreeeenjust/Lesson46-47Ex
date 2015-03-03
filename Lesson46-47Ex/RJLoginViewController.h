//
//  RJLoginViewController.h
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 03.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RJAccessToken;

typedef void(^RJLoginCompletionBlock)(RJAccessToken *token);

@interface RJLoginViewController : UIViewController
- (id)initWithCompletionBlock:(RJLoginCompletionBlock) completionBlock;
@end

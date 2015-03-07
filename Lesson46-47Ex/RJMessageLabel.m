//
//  RJMessageLabel.m
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 07.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJMessageLabel.h"

@implementation RJMessageLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 7, 0, 7};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end

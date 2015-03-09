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
    UIEdgeInsets insets = {0, 0, 0, 0};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end

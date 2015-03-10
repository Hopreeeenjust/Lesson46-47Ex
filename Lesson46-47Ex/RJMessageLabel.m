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

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    if (self.numberOfLines == 0 && bounds.size.width != self.preferredMaxLayoutWidth) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
        [self setNeedsUpdateConstraints];
    }
}

@end

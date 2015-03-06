//
//  RJMessage.m
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 06.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJMessage.h"

@implementation RJMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.lastMessageInterval = [[dictionary valueForKeyPath:@"message.date"] integerValue];
        self.text = [dictionary valueForKeyPath:@"message.body"];
    }
    return self;
}

@end

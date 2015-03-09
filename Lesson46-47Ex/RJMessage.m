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
        self.messageInterval = [[dictionary valueForKeyPath:@"date"] integerValue];
        self.text = [dictionary valueForKeyPath:@"body"];
        self.messageIsMine = [[dictionary valueForKeyPath:@"out"] boolValue];
        self.messageState = [[dictionary valueForKeyPath:@"read_state"] integerValue];
        self.messageID = [[dictionary valueForKeyPath:@"id"] integerValue];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MESSAGE: \ndate: %@", [NSDate dateWithTimeIntervalSince1970:self.messageInterval]];
}

@end

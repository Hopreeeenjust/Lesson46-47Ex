//
//  RJDialog.m
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 04.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJDialog.h"

@implementation RJDialog

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.lastMessageInterval = [[dictionary valueForKeyPath:@"message.date"] integerValue];
        self.lastMessageIsMine = [[dictionary valueForKeyPath:@"message.out"] boolValue];
        self.userID = [[dictionary valueForKeyPath:@"message.user_id"] integerValue];
        self.messageState = [[dictionary valueForKeyPath:@"message.read_state"] integerValue];
        self.text = [dictionary valueForKeyPath:@"message.body"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"DIALOG: \nlast message is mine: %d, \nuserID: %ld, \nmessage state: %ld, \nmessage text: %@", self.lastMessageIsMine, self.userID, self.messageState, self.text];
}

@end

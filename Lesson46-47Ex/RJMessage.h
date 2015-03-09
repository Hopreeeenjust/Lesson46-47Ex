//
//  RJMessage.h
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 06.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RJMessageState) {
    RJMessageStateUnread = 0,
    RJMessageStateRead
};

@interface RJMessage : NSObject
@property (assign, nonatomic) NSTimeInterval messageInterval;
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) BOOL messageIsMine;
@property (assign, nonatomic) RJMessageState messageState;
@property (assign, nonatomic) NSInteger messageID;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

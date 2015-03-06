//
//  RJDialog.h
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 04.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RJMessageState) {
    RJMessageStateUnread = 0,
    RJMessageStateRead
};

@interface RJDialog : NSObject
@property (assign, nonatomic) NSTimeInterval lastMessageInterval;
@property (assign, nonatomic) BOOL lastMessageIsMine;
@property (assign, nonatomic) NSInteger userID;
@property (assign, nonatomic) RJMessageState messageState;
@property (strong, nonatomic) NSString *text;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

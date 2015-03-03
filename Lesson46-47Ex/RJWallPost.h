//
//  RJWallPost.h
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 27.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJWallPost : NSObject
@property (assign, nonatomic) NSInteger userID;
@property (assign, nonatomic) NSInteger repostSourceID;
@property (strong, nonatomic) NSString *postDate;
@property (strong, nonatomic) NSString *repostDate;
@property (strong, nonatomic) NSArray *attachments;
@property (strong, nonatomic) NSArray *repostAttachments;
@property (strong, nonatomic) NSString *postText;
@property (strong, nonatomic) NSString *repostText;
@property (assign, nonatomic) NSInteger likes;
@property (assign, nonatomic) NSInteger reposts;
@property (assign, nonatomic) NSInteger comments;
@property (assign, nonatomic) BOOL hasRepost;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

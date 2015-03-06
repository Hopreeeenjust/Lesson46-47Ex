//
//  RJWallPost.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 27.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJWallPost.h"

@implementation RJWallPost

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.userID = [[dictionary valueForKey:@"from_id"] integerValue];
        self.repostSourceID = [[[dictionary valueForKeyPath:@"copy_history.owner_id"] firstObject] integerValue];
        self.postDate = [dictionary valueForKey:@"date"];
        self.repostDate = [[dictionary valueForKeyPath:@"copy_history.date"] firstObject];
        self.attachments = [dictionary valueForKey:@"attachments"];
        self.repostAttachments = [dictionary valueForKeyPath:@"copy_history.attachments"];
        self.postText = [dictionary valueForKey:@"text"];
        self.repostText = [[dictionary valueForKeyPath:@"copy_history.text"] firstObject];
        self.likes = [[dictionary valueForKeyPath:@"likes.count"] integerValue];
        self.reposts = [[dictionary valueForKeyPath:@"reposts.count"] integerValue];
        self.comments = [[dictionary valueForKeyPath:@"comments.count"] integerValue];
        self.hasRepost = [dictionary valueForKey:@"copy_history"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"POST: \nhas reposts: %d, \nuserID: %ld, \npostDate: %@, \nattachments count: %ld, \npostText: %@, \nlikes: %ld, \nreposts: %ld, \ncomments: %ld. \nREPOST: \nsourseID: %ld, \nrepostDate: %@, \nrepost attachments count: %ld, \nrepostText: %@", self.hasRepost, self.userID, self.postDate, [self.attachments count], self.postText, self.likes, self.reposts, self.comments, self.repostSourceID, self.repostDate, [self.repostAttachments count], self.repostText];
}

@end
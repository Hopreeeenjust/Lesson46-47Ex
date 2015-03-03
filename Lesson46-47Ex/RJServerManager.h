//
//  RJServerManager.h
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 25.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJUser;

@interface RJServerManager : NSObject
@property (strong, nonatomic, readonly) RJUser *currentUser;

+ (RJServerManager *)sharedManager;

- (void)authorizeUser:(void(^)(RJUser *user)) completion;

- (void) getUser:(NSString*) userID
       onSuccess:(void(^)(RJUser* user)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getFriendsForId:(NSInteger)friendId
               withCount:(NSInteger)count
               andOffset:(NSInteger)offset
               onSuccess:(void(^)(NSArray *friends))success
               onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void) getFriendInfoForId:(NSInteger)friendId
                  onSuccess:(void(^)(NSArray *friends))success
                  onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void) getFollowersForId:(NSInteger)friendId
                 withCount:(NSInteger)count
                 andOffset:(NSInteger)offset
                 onSuccess:(void(^)(NSArray *followers))success
                 onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void) getGroupsForId:(NSInteger)userId
              withCount:(NSInteger)count
              andOffset:(NSInteger)offset
              onSuccess:(void(^)(NSArray *friends))success
              onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void) getWallForId:(NSInteger)ownerID
            withCount:(NSInteger)count
            andOffset:(NSInteger)offset
            onSuccess:(void(^)(NSArray *posts, NSArray *users, NSArray *groups))success
            onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;
@end

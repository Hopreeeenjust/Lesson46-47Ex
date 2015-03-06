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
@property (strong, nonatomic) RJUser *loggedUser;

+ (RJServerManager *)sharedManager;

- (void)authorizeUser:(void(^)(RJUser *user)) completion;

- (void)getUser:(NSArray *)userIDs
      onSuccess:(void(^)(NSArray *users)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getFriendsForId:(NSInteger)friendId
               withCount:(NSInteger)count
               andOffset:(NSInteger)offset
               onSuccess:(void(^)(NSArray *friends))success
               onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void) getUserInfoForId:(NSInteger)friendId
                onSuccess:(void(^)(NSArray *userInfo))success
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
           withFilter:(NSString *)filter
            onSuccess:(void(^)(NSArray *posts, NSArray *users, NSArray *groups))success
            onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)postText:(NSString *)text
          onWall:(NSString *)ownerID
       onSuccess:(void(^)(id result))success
       onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)getDialogsWithCount:(NSInteger)count
                  andOffset:(NSInteger)offset
                  onSuccess:(void(^)(NSArray *dialogs))success
                  onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)getMessageHistoryWithFriendId:(NSInteger)userID
                            withCount:(NSInteger)count
                            andOffset:(NSInteger)offset
                            onSuccess:(void(^)(NSArray *messages, NSNumber *totalCount))success
                            onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;
@end

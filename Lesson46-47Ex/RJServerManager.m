//
//  RJServerManager.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 25.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJServerManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "RJUser.h"
#import "RJLoginViewController.h"
#import "RJAccessToken.h"

@interface RJServerManager ()
@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;
@property (strong, nonatomic) RJAccessToken *accessToken;
@end

@implementation RJServerManager

+ (RJServerManager *)sharedManager {
    static RJServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [RJServerManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *urlString = @"https://api.vk.com/method/";
        NSURL *url = [NSURL URLWithString:urlString];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}

- (void) authorizeUser:(void(^)(RJUser *user)) completion {
    
    RJLoginViewController* vc = [[RJLoginViewController alloc] initWithCompletionBlock:^(RJAccessToken *token) {
        self.accessToken = token;
        if (token) {
            accessTokenExpirationDate = token.expirationDate;
            [self getUser:@[self.accessToken.userID]
                onSuccess:^(NSArray *users) {
                    if (completion) {
                        RJUser *user = [users firstObject];
                        self.loggedUser = user;
                        completion(user);
                    }
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    if (completion) {
                        completion(nil);
                    }
                }];
        } else if (completion) {
            completion(nil);
        }
    }];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    [mainVC presentViewController:nav
                         animated:YES
                       completion:nil];
}

- (void)getUser:(NSArray *)userIDs
      onSuccess:(void(^)(NSArray *users)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params = @{
                             @"user_ids": userIDs,
                             @"fields": @"photo_100, online, online_mobile",
                             @"name_case": @"nom",
                             @"v": (@5.28)};
    
    [self.requestOperationManager
     GET:@"users.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         if ([dictsArray count] > 0) {
             NSMutableArray *users = [NSMutableArray array];
             for (NSDictionary *userDict in dictsArray) {
                 RJUser* user = [[RJUser alloc] initWithDictionary:userDict];
                 [users addObject:user];
             }
             if (success) {
                 success(users);
             }
         } else {
             if (failure) {
                 failure(nil, operation.response.statusCode);
             }
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
}

- (void)getFriendsForId:(NSInteger)friendId
              withCount:(NSInteger)count
              andOffset:(NSInteger)offset
              onSuccess:(void(^)(NSArray *friends))success
              onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"user_id": @(friendId),
                                 @"order": @"name",
                                 @"count": @(count),
                                 @"offset": @(offset),
                                 @"fields": @[@"photo_100", @"online"],
                                 @"name_case": @"nom",
                                 @"v": (@5.28)};

    [self.requestOperationManager GET:@"friends.get?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSArray *friends = [[responseObject valueForKey:@"response"] valueForKey:@"items"];
                                  if (success) {
                                      success(friends);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)getUserInfoForId:(NSInteger)friendId
               onSuccess:(void(^)(NSArray *userInfo))success
               onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"user_ids": @(friendId),
                                 @"fields": @[@"photo_100", @"bdate", @"city", @"country", @"photo_max", @"online", @"online_mobile", @"last_seen", @"counters", @"can_post", @"can_write_private_message", @"sex", @"status"],
                                 @"name_case": @"nom",
                                 @"lang": @"ru",
                                 @"access_token": self.accessToken.token,
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"users.get?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSArray *friends = [responseObject valueForKey:@"response"];
                                  if (success) {
                                      success(friends);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)getFollowersForId:(NSInteger)friendId
                withCount:(NSInteger)count
                andOffset:(NSInteger)offset
                onSuccess:(void(^)(NSArray *followers))success
                onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"user_id": @(friendId),
                                 @"count": @(count),
                                 @"offset": @(offset),
                                 @"fields": @[@"photo_100", @"online"],
                                 @"name_case": @"nom",
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"users.getFollowers?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSArray *followers = [[responseObject valueForKey:@"response"] valueForKey:@"items"];
                                  if (success) {
                                      success(followers);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)getUserFollowingsForId:(NSInteger)friendId
                     withCount:(NSInteger)count
                     andOffset:(NSInteger)offset
                     onSuccess:(void(^)(NSArray *followers))success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"user_id": @(friendId),
                                 @"count": @(count),
                                 @"offset": @(offset),
                                 @"fields": @[@"photo_100", @"online"],
                                 @"name_case": @"nom",
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"users.getFollowers?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSArray *followers = [[responseObject valueForKey:@"response"] valueForKey:@"items"];
                                  if (success) {
                                      success(followers);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)getGroupsForId:(NSInteger)userId
             withCount:(NSInteger)count
             andOffset:(NSInteger)offset
             onSuccess:(void(^)(NSArray *groups))success
             onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"user_id": @(userId),
                                 @"extended": @1,
                                 @"count": @(count),
                                 @"offset": @(offset),
                                 @"fields": @[@"city", @"country", @"members_count"],
                                 @"access_token": self.accessToken.token,
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"groups.get?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSArray *groups = [[responseObject valueForKey:@"response"] valueForKey:@"items"];
                                  if (success) {
                                      success(groups);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)getWallForId:(NSInteger)ownerID
           withCount:(NSInteger)count
           andOffset:(NSInteger)offset
          withFilter:(NSString *)filter
           onSuccess:(void(^)(NSArray *posts, NSArray *users, NSArray *groups))success
           onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"owner_id": @(ownerID),
                                 @"extended": @1,
                                 @"count": @(count),
                                 @"offset": @(offset),
                                 @"filter": filter,
                                 @"lang": @"ru",
                                 @"access_token": self.accessToken.token,
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"wall.get?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSArray *posts = [responseObject valueForKeyPath:@"response.items"];
                                  NSArray *users = [responseObject valueForKeyPath:@"response.profiles"];
                                  NSArray *groups = [responseObject valueForKeyPath:@"response.groups"];
                                  if (success) {
                                      success(posts, users, groups);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)postText:(NSString *)text
          onWall:(NSString *)ownerID
       onSuccess:(void(^)(id result))success
       onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSDictionary *params = @{@"owner_id": ownerID,
                             @"message": text,
                             @"access_token": self.accessToken.token,
                             @"v": @"5.28"};
    
    [self.requestOperationManager POST:@"wall.post?"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         if (success) {
             success(responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
}

- (void)getDialogsWithCount:(NSInteger)count
                  andOffset:(NSInteger)offset
                  onSuccess:(void(^)(NSArray *dialogs))success
                  onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"count": @(count),
                                 @"offset": @(offset),
                                 @"access_token": self.accessToken.token,
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"messages.getDialogs?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSArray *dialogs = [[responseObject valueForKey:@"response"] valueForKey:@"items"];
                                  if (success) {
                                      success(dialogs);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)getMessageHistoryWithFriendId:(NSInteger)userID
                            withCount:(NSInteger)count
                            andOffset:(NSInteger)offset
                            onSuccess:(void(^)(NSArray *messages, NSNumber *totalCount))success
                            onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"count": @(count),
                                 @"offset": @(offset),
                                 @"user_id": @(userID),
                                 @"access_token": self.accessToken.token,
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"messages.getHistory?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSArray *messages = [[responseObject valueForKey:@"response"] valueForKey:@"items"];
                                  NSNumber *totalCount = [[responseObject valueForKey:@"response"] valueForKey:@"count"];
                                  if (success) {
                                      success(messages, totalCount);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)sendMessage:(NSString *)message
       toUserWithID:(NSInteger)userID
          onSuccess:(void(^)(id result))success
          onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"user_id": @(userID),
                                 @"message": message,
                                 @"access_token": self.accessToken.token,
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"messages.send?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (success) {
                                      success(responseObject);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

- (void)markAllMessagesAsRead:(NSString *)userIDs
                    onSuccess:(void(^)(id result))success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    NSDictionary *parameters = @{
                                 @"message_ids": userIDs,
                                 @"access_token": self.accessToken.token,
                                 @"v": (@5.28)};
    
    [self.requestOperationManager GET:@"messages.markAsRead?"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (success) {
                                      success(responseObject);
                                  }
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  failure(error, error.code);
                              }];
}

@end


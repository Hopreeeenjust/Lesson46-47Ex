//
//  RJUser.h
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 25.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RJUserGender) {
    RJUserGenderFemale = 1,
    RJUserGenderMale
};

@interface RJUser : NSObject
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *originalImageUrl;
@property (assign, nonatomic) NSInteger userID;
@property (strong, nonatomic) NSString *birthDate;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (assign, nonatomic) NSInteger lastSeen;
@property (assign, nonatomic) BOOL online;
@property (assign, nonatomic) BOOL onlineMobile;
@property (assign, nonatomic) NSInteger friendsCount;
@property (assign, nonatomic) NSInteger groupsCount;
@property (assign, nonatomic) NSInteger followersCount;
@property (assign, nonatomic) BOOL canPost;
@property (assign, nonatomic) BOOL canSendMessage;
@property (assign, nonatomic) RJUserGender gender;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
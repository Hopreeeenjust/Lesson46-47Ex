//
//  RJAccessToken.h
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 03.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJAccessToken : NSObject
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSDate *expirationDate;
@property (strong, nonatomic) NSString *userID;
@end

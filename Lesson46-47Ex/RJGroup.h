//
//  RJGroup.h
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 27.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJGroup : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *originalImageUrl;
@property (assign, nonatomic) NSInteger groupID;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

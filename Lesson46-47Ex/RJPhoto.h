//
//  RJImage.h
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 01.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJPhoto : NSObject
@property (strong, nonatomic) NSString *imageUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

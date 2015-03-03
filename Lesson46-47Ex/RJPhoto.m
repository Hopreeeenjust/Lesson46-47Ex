//
//  RJImage.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 01.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJPhoto.h"

@implementation RJPhoto

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.imageUrl = [dictionary valueForKeyPath:@"photo.photo_604"];
    }
    return self;
}

@end

//
//  RJGroup.m
//  Lesson45Ex
//
//  Created by Hopreeeeenjust on 27.02.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJGroup.h"

@implementation RJGroup

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = [dictionary valueForKey:@"name"];
        self.imageUrl = [dictionary valueForKey:@"photo_100"];
        self.originalImageUrl = [dictionary valueForKey:@"photo_max"];
        self.city = [dictionary valueForKeyPath:@"city.title"];
        self.country = [dictionary valueForKeyPath:@"country.title"];
        self.groupID = [[dictionary valueForKey:@"id"] integerValue];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"GROUP name: %@, id: %ld", self.name, self.groupID];
}

@end

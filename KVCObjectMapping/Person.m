//
//  Person.m
//  KVCObjectMapping
//
//  Created by Tuyen Nguyen on 12-11-08.
//  Copyright (c) 2012 SiliconSpots. All rights reserved.
//

#import "Person.h"

@implementation Hobby


@end

@implementation Address

@end

@implementation Vehicle

@end

@implementation Person

- (id)init
{
    self = [super init];
    if (self) {
        _address = [[Address alloc] init];
        _vehicles = [[KVCArray alloc] initWithClass:NSClassFromString(@"Vehicle")];
        _hobbies = [[KVCArray alloc] initWithClass:[Hobby class]];
    }
    return self;
}

@end

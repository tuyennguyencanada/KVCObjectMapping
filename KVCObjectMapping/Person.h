//
//  Person.h
//  KVCObjectMapping
//
//  Created by Tuyen Nguyen on 12-11-08.
//  Copyright (c) 2012 SiliconSpots. All rights reserved.
//

#import "KVCObject.h"

@interface Hobby : KVCObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;

@end

@interface Address : KVCObject

@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *postalCode;

@end

@interface Vehicle : KVCObject

@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;

@end

@interface Person : KVCObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) Address *address;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) KVCArray *vehicles;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) KVCArray *hobbies;

@end

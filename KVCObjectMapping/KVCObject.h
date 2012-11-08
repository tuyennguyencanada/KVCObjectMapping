//
//  KVCObject.h
//  KVCObjectMapping
//
//  Created by Tuyen Nguyen on 12-11-07.
//  Copyright (c) 2012 SiliconSpots. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface KVCArray: NSArray

@property (nonatomic, assign) Class elementClass;

- (id)initWithClass:(Class) element andCapacity:(NSUInteger) numItems;
- (id)initWithClass:(Class) element;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;

@end

/***********************************************/

@interface KVCObject : NSObject

- (NSMutableDictionary*)toDictionary;

@end

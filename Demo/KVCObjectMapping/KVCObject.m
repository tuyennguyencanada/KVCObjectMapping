//
//  KVCObject.m
//  KVCObjectMapping
//
//  Created by Tuyen Nguyen on 12-11-07.

//  Copyright (c) 2012 PropertySpots Inc.
//  The MIT License (MIT)
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "KVCObject.h"

@interface KVCArray()

@property (nonatomic, strong) NSMutableArray *realArray;

@end

@implementation KVCArray

static id NotSupported(){
    NSException* myException = [NSException
                                exceptionWithName:@"InvalidInitializer"
                                reason:@"Only initWithClass: and initWithClass:andCapacity: supported"
                                userInfo:nil];
    //---Only developers can see this exception
    @throw myException;
}

#pragma mark -
#pragma mark Initialization
- (id)init{
    return NotSupported();
}

- (id) initWithClass:(Class)element{
    self = [super init];
    if (self){
        _realArray = [[NSMutableArray alloc] init];
        _elementClass = element;
    }
    return self;
}

- (id) initWithClass:(Class) element andCapacity:(NSUInteger) numItems{
    self = [super init];
    if (self){
        _elementClass = element;
        _realArray = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}

#pragma mark -
#pragma mark Array handling

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index{
    if ([anObject isKindOfClass:self.elementClass]){
        [_realArray insertObject:anObject atIndex:index];
    }
}

- (void) removeObjectAtIndex:(NSUInteger)index{
    [_realArray removeObjectAtIndex:index];
}

-(id) objectAtIndex:(NSUInteger)index{
    return _realArray[index];
}

-(NSUInteger) count{
    return [_realArray count];
}

@end

/***********************************************/
#pragma mark -
#pragma mark -
#pragma mark -
@implementation KVCObject

#pragma mark -
#pragma mark - Public methods

+ (NSArray*)iVarNames{
    return [self iVarNamesForClass:[self class]];
}

+ (NSArray*)iVarNamesForClass:(Class)aClass{
    Ivar *ivars;// all ivars of a class
    unsigned int ivarsCount;// total number of ivars of a class
    NSMutableArray *iVarNames = nil;
    ivars = class_copyIvarList(aClass, &ivarsCount);
    if (ivars != nil){
        //Get array of ivars from super class
        NSArray *iVarNamesSuperClass = [KVCObject iVarNamesForClass:class_getSuperclass(aClass)];
        //
        iVarNames = [NSMutableArray arrayWithArray:iVarNamesSuperClass];
        //add ivars from this current class to result array
        while (ivarsCount--){
            [iVarNames addObject:@(ivar_getName(ivars[ivarsCount]))];
        }
    }
    free(ivars);
    return iVarNames;
}

#pragma mark -
#pragma mark - Get keys

- (NSMutableArray*)getKeys{
    NSMutableArray *realIvars = [NSMutableArray arrayWithArray:[[self class] iVarNames]];
    [realIvars removeObject:@"isa"];// |isa| is an unneccessary attributes
    return realIvars;
}

- (id)getChildObjectWithKey:(NSString *)key{
    /*
    //First character of the property name
    NSString *firstCharacter = [[key substringToIndex:1] lowercaseString];
    if ([firstCharacter isEqualToString:@"_"])
    {
        firstCharacter = @"";
    }
    //Get the property name of the key (property name starts with lower case letter)
    NSString *propertyName = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                          withString:firstCharacter];
    */
    //Create a selector from a property name
    SEL propertySelector = NSSelectorFromString(lowerCaseFirstLetter(key));
    //Get the object (which is a property of an instance) by perform the selector
    id resultChildObject = nil;
    if ([self respondsToSelector:propertySelector]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"//suppress ARC warning
        resultChildObject = [self performSelector:propertySelector];
#pragma clang diagnostic pop
    }
    return resultChildObject;
}

#pragma mark -
#pragma mark - Set values

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //Do nothing for undefined key
}

- (void)setChildDictionaryValue:(NSDictionary *)dictionary forKey:(NSString *)key{
    [[self getChildObjectWithKey:key] setValuesForKeysWithDictionary:dictionary];
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([value isKindOfClass:[NSDictionary class]]){//value is a complex object
        id childObject = [self getChildObjectWithKey:key];
        [childObject setValuesForKeysWithDictionary:value];
    }
    else if ([value isKindOfClass:[NSArray class]]){//value is an array of objects
        //Get array of data objects
        NSArray *dataObjects = [NSArray arrayWithArray:value];//data to populate
        KVCArray *objects = (KVCArray*)[self getChildObjectWithKey:key];//array property to be populated
        for (int i=0; i<dataObjects.count; i++){
            //Prepare element object
            id object = nil;
            if (objects.elementClass==[NSString class]){
                object = [[NSString alloc] init];
            }
            else{
                object = [[objects.elementClass alloc] init];
            }
            //Get data for element object
            id data = dataObjects[i];
            if ([data isKindOfClass:[NSDictionary class]]){//data is a complex object
                [object setValuesForKeysWithDictionary:data];
            }
            else{//data is a simple type
                object = data;
            }
            //insert element object array of objects, the objects array should already initiated
            [objects insertObject:object atIndex:i];
        }
        [super setValue:objects forKey:key];
    }
    else{// value is a simple variable
        [super setValue:value forKey:key];
    }
}

#pragma mark -
#pragma mark - Object to Dictionary

NSString* lowerCaseFirstLetter(NSString* key)
{
    //First character of the property name
    NSString *firstCharacter = [[key substringToIndex:1] lowercaseString];
    if ([firstCharacter isEqualToString:@"_"])
    {
        firstCharacter = @"";
    }
    //Get the property name of the key (property name starts with lower case letter)
    NSString *result = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                          withString:firstCharacter];
    return result;
}

NSString* upperCaseFirstLetter(NSString* key)
{
    //First character of the property name
    NSString *firstCharacter = [[key substringToIndex:1] uppercaseString];
    if ([firstCharacter isEqualToString:@"_"])
    {
        firstCharacter = @"";
        key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                     withString:firstCharacter];
        firstCharacter = [[key substringToIndex:1] uppercaseString];
    }
    //Get the property name of the key (property name starts with lower case letter)
    NSString *result = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                    withString:firstCharacter];
    return result;
}

- (NSMutableDictionary*)toDictionary
{
    NSArray *keys = [self getKeys];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *key in keys)
    {
        id object = [self getChildObjectWithKey:key];
        if ([object respondsToSelector:@selector(getKeys)])//this is a complex object
        {
            object = [object toDictionary];
        }
        else if([object isKindOfClass:[NSArray class]])//this is an array
        {
            NSMutableArray *subObjects = [NSMutableArray array];
            for (id subObject in object)
            {
                if ([subObject respondsToSelector:@selector(getKeys)])
                {
                    [subObjects addObject:[subObject toDictionary]];
                }
                else
                {
                    [subObjects addObject:subObject];
                }
            }
            object = [NSArray arrayWithArray:subObjects];
        }
        [dictionary setValue:object forKey:upperCaseFirstLetter(key)];
    }
    return dictionary;
}

@end

//
//  DataBase.h
//  LearnFMDB
//
//  Created by Roy on 2018/3/16.
//  Copyright © 2018年 Roy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Person;
@class Car;

@interface DataBase : NSObject

+ (instancetype)shareDataBase;

- (void)addPerson:(Person *)person;
- (void)deletePerson:(Person *)person;
- (void)updatePerson:(Person *)person;

- (NSMutableArray *)getAllPerson;


/// car 相关
- (void)addCar:(Car *)car toPerson:(Person *)person;
- (void)deleteCar:(Car *)car fromPerson:(Person *)person;
- (void)deleteAllCarsFromPerson:(Person *)person;
- (void)updateCar:(Car *)car fromPerson:(Person *)person;

- (NSMutableArray *)getAllCarsFromPerson:(Person *)person;

@end

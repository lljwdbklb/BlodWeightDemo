//
//  HistoryPersonData.h
//  BlodWeightDemo
//
//  Created by apple on 16/4/6.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

#import <Realm/Realm.h>
#import "LockScalesData.h"

@interface HistoryPersonData : RLMObject
@property (nonatomic, assign) BOOL sex;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) LockScalesData *data;
@end

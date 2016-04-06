//
//  LockScalesData.m
//  HealthyGuard
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 ekangzhi. All rights reserved.
//

#import "LockScalesData.h"

#define kHexScale (16 * 16)

@implementation LockScalesData
//+ (NSDictionary *)mapping {
//    NSMutableDictionary *mapping = [NSMutableDictionary dictionaryWithDictionary:[super mapping]];
//    FMDBORMColumnPackDict(mapping, @"weight", FMDBORMTypeReal);
//    FMDBORMColumnPackDict(mapping, @"fat", FMDBORMTypeReal);
//    FMDBORMColumnPackDict(mapping, @"whater", FMDBORMTypeReal);
//    FMDBORMColumnPackDict(mapping, @"muscle", FMDBORMTypeReal);
//    FMDBORMColumnPackDict(mapping, @"metabolism", FMDBORMTypeReal);
//    FMDBORMColumnPackDict(mapping, @"skeleton", FMDBORMTypeReal);
//    FMDBORMColumnPackDict(mapping, @"state", FMDBORMTypeInteger);
//    FMDBORMColumnPackDict(mapping, @"subtime", FMDBORMTypeText);
//    
//    return [mapping copy];
//}


+ (id)dataWithDatas:(NSArray <NSNumber *>*)datas {
    return [[self alloc]initWithDatas:datas];
}


- (instancetype)initWithDatas:(NSArray <NSNumber *>*)datas{
    if (datas.count != 16) return nil;
    if (self = [self init]) {
        NSInteger d = [datas[1] integerValue];
        NSInteger d2 = [datas[0] integerValue];
        NSInteger w = d2 + d * kHexScale;
        self.weight = w / 10.0f;
        
        self.state = [datas[2] integerValue];
        //脂肪
        d = [datas[4] integerValue];
        d2 = [datas[3] integerValue];
        self.fat = (d2 + d * kHexScale) / 10.f;
        //水分
        d = [datas[6] integerValue];
        d2 = [datas[5] integerValue];
        self.whater = (d2 + d * kHexScale) / 10.f;
        
        //肌肉
        d = [datas[8] integerValue];
        d2 = [datas[7] integerValue];
        self.muscle = (d2 + d * kHexScale) / 10.f;
        
        //代谢
        d = [datas[10] integerValue];
        d2 = [datas[9] integerValue];
        self.metabolism = (d2 + d * kHexScale) / 10.f;
        
        //骨骼
        d = [datas[11] integerValue];
        self.skeleton = d / 10.0;
        
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _subtime = [format stringFromDate:[NSDate date]];
    }
    return self;
}

//+ (NSArray *)lockScalesesAtDBTime:(NSString *)time {
////    User *u = nil;
//    
//    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE subtime LIKE '%@%%'", [self tableName],time];
//    __block NSArray *array = nil;
//    [DBManagerQueue inDatabase:^(FMDatabase *db) {
//        FMResultSet *rs = [db executeQuery:sql];
//        array = [self newObjectsWithResultSet:rs];
//    }];
////    u = [array firstObject];
//    return array;
//}

@end

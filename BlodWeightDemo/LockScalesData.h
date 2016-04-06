//
//  LockScalesData.h
//  HealthyGuard
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 ekangzhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface LockScalesData : RLMObject

+ (id)dataWithDatas:(NSArray <NSNumber *>*)datas;
@property (assign, nonatomic)   float weight;       //体重
@property (assign, nonatomic)   NSInteger state;    //工作状态
@property (assign, nonatomic)   float fat;          //脂肪
@property (assign, nonatomic)   float whater;       //水分
@property (assign, nonatomic)   float muscle;       //肌肉
@property (assign, nonatomic)   float metabolism;   //代谢
@property (assign, nonatomic)   float skeleton;     //骨骼
@property (copy, nonatomic)     NSString *subtime;  //提交时间

+ (NSArray *)lockScalesesAtDBTime:(NSString *)time;//yyyy-MM-dd
@end

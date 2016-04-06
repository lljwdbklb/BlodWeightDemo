//
//  TemporaryScalesData.h
//  HealthyGuard
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 ekangzhi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemporaryScalesData : NSObject
+ (id)dataWithDatas:(NSArray <NSNumber *>*)datas;
@property (assign, nonatomic) float weight;     //体重
@property (copy, nonatomic) NSString *subtime;  //提交时间
@end

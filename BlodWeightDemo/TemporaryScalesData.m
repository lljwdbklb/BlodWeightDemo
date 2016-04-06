//
//  TemporaryScalesData.m
//  HealthyGuard
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 ekangzhi. All rights reserved.
//

#import "TemporaryScalesData.h"

#define kHexScale (16 * 16)

@implementation TemporaryScalesData
+ (id)dataWithDatas:(NSArray <NSNumber *>*)datas {
    return [[self alloc] initWithDatas:datas];
}

- (instancetype)initWithDatas:(NSArray <NSNumber *>*)datas{
    if (datas.count != 2) return nil;
    if (self = [self init]) {
        NSInteger d = [datas[1] integerValue];
        NSInteger d2 = [datas[0] integerValue];
        NSInteger w = d2 + d * kHexScale;
        self.weight = w / 10.0f;
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _subtime = [format stringFromDate:[NSDate date]];
    }
    return self;
}
@end

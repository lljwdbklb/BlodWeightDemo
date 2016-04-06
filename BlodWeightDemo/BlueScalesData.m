//
//  BlueScalesData.m
//  HealthyGuard
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 ekangzhi. All rights reserved.
//

#import "BlueScalesData.h"

@implementation BlueScalesData
@synthesize cmd = cmd;

+ (id)scalesDataWithBytes:(const uint8_t * )bytes length:(NSUInteger)length {
    return [[self alloc] initWithBytes:bytes length:length];
}
- (instancetype)initWithBytes:(const uint8_t * )bytes length:(NSUInteger)length {
    if (self = [super init]) {
        _header = bytes[0];
        cmd = bytes[1];
        NSInteger l = bytes[2];
        NSMutableArray *arrayM =[NSMutableArray array];
        for (int i = 1; i <= l; i++) {
            NSInteger d = bytes[2 + i];
            [arrayM addObject:@(d)];
        }
        _data = [arrayM copy];
        _fcs = bytes[length - 1];

        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _subtime = [format stringFromDate:[NSDate date]];
    }
    return self;
}
@end

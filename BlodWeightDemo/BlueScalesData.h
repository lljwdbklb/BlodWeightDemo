//
//  BlueScalesData.h
//  HealthyGuard
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 ekangzhi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlueScalesData : NSObject
- (instancetype)initWithBytes:(const uint8_t *)bytes length:(NSUInteger)length;
+ (id)scalesDataWithBytes:(const uint8_t *)bytes length:(NSUInteger)length;
@property (nonatomic, assign, readonly) NSInteger header;
@property (nonatomic, assign, readonly) NSInteger cmd;
@property (nonatomic, assign, readonly) NSInteger fcs;
@property (nonatomic, copy, readonly) NSArray <NSNumber *>*data;
@property (nonatomic, copy, readonly) NSString *subtime;
@end

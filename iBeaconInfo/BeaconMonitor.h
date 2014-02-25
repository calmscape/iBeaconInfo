//
//  BeaconMonitor.h
//  iBeaconInfo
//
//  Created by Masahiro Murase on 2014/02/20.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconMonitor : NSObject
/**
 UUIDを指定してレンジングを開始する。
 既にレンジングしている場合は、新たなUUIDでレンジングする。
 */
- (void)startRangingWithProximityUUID:(NSString *)uuidString;

/**
 レンジングを停止する
 */
- (void)stopRanging;

@end

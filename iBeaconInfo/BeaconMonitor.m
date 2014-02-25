//
//  BeaconMonitor.m
//  iBeaconInfo
//
//  Created by Masahiro Murase on 2014/02/20.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

@import CoreLocation;
#import "BeaconMonitor.h"

static NSString* const kMyBeaconRegionIdentifier = @"edu.self.myBeacon";

@interface BeaconMonitor () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLBeaconRegion *rangingBeaconRegion;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *foundBeacons;
@end

@implementation BeaconMonitor
- (id)init
{
    self = [super init];
    if (self) {
		_rangingBeaconRegion = nil;
		_foundBeacons = [NSMutableArray array];

		if ([CLLocationManager locationServicesEnabled]) {
			NSAssert([NSThread isMainThread], @"CLLocationManager must be allocated on the main thread.");
			_locationManager = [CLLocationManager new];
			_locationManager.delegate = self;
		}
    }
    return self;
}

#pragma mark - Public instance methods
- (void)startRangingWithProximityUUID:(NSString *)uuidString;
{
	if ([CLLocationManager isRangingAvailable]) {
		NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
		self.rangingBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
																	  identifier:kMyBeaconRegionIdentifier];
		[self.locationManager startRangingBeaconsInRegion:self.rangingBeaconRegion];
		/**
		 ・位置情報サービスオフだろうがアプリの位置情報利用許可しないとかになっててもとりあえず呼んでおけば、許可されてフォアグラウンドになったら勝手にはじまってくれる
		 ・identifierが同じならレンジング対象のリージョンを上書きする。つぎにlocationManager:didRangeBeacons:inRegion:が呼ばれたときには変更されている。ので、既に登録してたら解除、みたいなコードは要らない。
		 */
		
	}
}

- (void)stopRanging
{
	if ([CLLocationManager isRangingAvailable] && self.rangingBeaconRegion) {
		[self.locationManager stopRangingBeaconsInRegion:self.rangingBeaconRegion];
		self.rangingBeaconRegion = nil;
	}
}

#pragma mark - CLLocationManagerDelegate protocol method
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	NSLog(@"%s, status=%d", __PRETTY_FUNCTION__, status);

	if (status == kCLAuthorizationStatusDenied) {
		NSLog(@"アプリの位置情報サービスをONにしてね");
	}
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	/**
	 ・regionインスタンスは毎回変わる
	 ・レンジング開始時にmajor,minorを指定しない場合はregionにも入っていない
	 ・beacons配列にはCLBeaconオブジェクトが入っており、accuracyで昇順(小から大)ソートされている
	 ・CLProximityUnknownなビーコンは距離が-1mになる
	 ・結果的にCLBeaconオブジェクトがUnknown, Immediate, Near, Farの順にbeacons配列に詰められてくるので、
	 　一番近い距離にあるビーコンを取得するために[beacons firstObject]をするとCLProximityUnknownのCLBeaconが返ることがあるので注意。
		(アップルのプログラミングガイドは罠)
	 */

	self.foundBeacons = [NSArray arrayWithArray:beacons];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"didRangeBeacons"
														object:self
													  userInfo:@{@"beacons" : self.foundBeacons}];

}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
	NSLog(@"%s, %@", __PRETTY_FUNCTION__, [error localizedDescription]);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end

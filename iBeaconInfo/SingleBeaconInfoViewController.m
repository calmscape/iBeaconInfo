//
//  SingleBeaconInfoViewController.m
//  iBeaconInfo
//
//  Created by Masahiro Murase on 2014/01/24.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

@import CoreLocation;
#import "SingleBeaconInfoViewController.h"

@interface SingleBeaconInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@end

@implementation SingleBeaconInfoViewController

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRangeBeacons:)
												 name:@"didRangeBeacons"
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter notification reciever
-(void)didRangeBeacons:(NSNotification *)notification
{
	NSArray *beacons = notification.userInfo[@"beacons"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proximityUUID == %@ && major == %@ && minor ==%@",
							  self.monitoredBeaconRegion.proximityUUID,
							  self.monitoredBeaconRegion.major,
							  self.monitoredBeaconRegion.minor];
	NSArray *validBeacons = [beacons filteredArrayUsingPredicate:predicate];
	CLBeacon *beacon = [validBeacons firstObject];
	if (beacon) {
		self.uuidLabel.text = [NSString stringWithFormat:@"%@", beacon.proximityUUID.UUIDString];
		self.majorLabel.text = [beacon.major stringValue];
		self.minorLabel.text = [beacon.minor stringValue];
		self.accuracyLabel.text = [NSString stringWithFormat:@"%.4f [m]", beacon.accuracy];
		{
			NSArray *proximityStrings = @[@"Unknown", @"Immediate", @"Near", @"Far"];
			self.proximityLabel.text = proximityStrings[beacon.proximity];
		}
		self.rssiLabel.text = [NSString stringWithFormat:@"%ld [dBm]", (long)beacon.rssi];
	}
	else {
		self.uuidLabel.text = [NSString stringWithFormat:@"%@", self.monitoredBeaconRegion.proximityUUID.UUIDString];
		self.majorLabel.text = [self.monitoredBeaconRegion.major stringValue];
		self.minorLabel.text = [self.monitoredBeaconRegion.minor stringValue];
		self.accuracyLabel.text = @"---";
		self.proximityLabel.text = @"---";
		self.rssiLabel.text = @"---";
	}
	
	[self.tableView reloadData];
}
@end

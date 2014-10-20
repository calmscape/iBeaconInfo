//
//  RangingTableViewController.m
//  iBeaconInfo
//
//  Created by Masahiro Murase on 2013/10/28.
//  Copyright (c) 2013年 calmscape. All rights reserved.
//

@import CoreLocation;
#import "BeaconMonitor.h"
#import "RangingTableViewController.h"
#import "SingleBeaconInfoViewController.h"

static NSString* const kDefaultBeaconProximityUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";	//Estimote UUID

@interface RangingTableViewController ()
@property (nonatomic, strong) BeaconMonitor *beaconMonitor;
@property (nonatomic, strong) NSString *rangingUUIDString;
@property (nonatomic, strong, readwrite) NSArray *foundBeacons;
@property (nonatomic, assign, getter = isSortEnabled) BOOL sortEnabled;
@property (nonatomic, strong) NSArray *cellSettings;

// Outlets & Actions
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
- (IBAction)didPushSortButton:(id)sender;
@end


@implementation RangingTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

	_foundBeacons = nil;
	_sortEnabled = NO;
	_cellSettings = @[
					  @{
						  @"proximity" : @"Unknown",
						  @"cellColor" : [UIColor colorWithWhite:0.4 alpha:1.0],
						  },
					  @{
						  @"proximity" : @"Immediate",
						  @"cellColor" : [UIColor colorWithRed:0.4 green:0.9 blue:0.4 alpha:1.0],
						  },
					  @{
						  @"proximity" : @"Near",
						  @"cellColor" : [UIColor colorWithRed:0.9 green:0.4 blue:0.4 alpha:1.0],
						  },
					  @{
						  @"proximity" : @"Far",
						  @"cellColor" : [UIColor colorWithWhite:1.0 alpha:1.0],
						  },
					  ];

	_beaconMonitor = [BeaconMonitor new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.rangingUUIDString = kDefaultBeaconProximityUUID;

	// Configure views
	self.sortButton.selected = self.isSortEnabled;
	[[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil]
	 setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption2]];
	
	[self.beaconMonitor startRangingWithProximityUUID:self.rangingUUIDString];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	NSLog(@"%s", __PRETTY_FUNCTION__);
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRangeBeacons:)
												 name:@"didRangeBeacons"
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UITableViewController *controller = segue.sourceViewController;
	NSIndexPath *selectedIndexPath = [controller.tableView indexPathForSelectedRow];
	
	[segue.destinationViewController setMonitoredBeaconRegion:(CLBeacon *)self.foundBeacons[selectedIndexPath.row]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource protovol methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return [NSString stringWithFormat:@"%@ (%ld)", self.rangingUUIDString, (unsigned long)[self.foundBeacons count]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.foundBeacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	CLBeacon *beacon = self.foundBeacons[indexPath.row];
	NSDictionary *cellSetting = self.cellSettings[beacon.proximity];

	cell.textLabel.text = [NSString stringWithFormat:@"major:%d, minor:%d",
						   beacon.major.intValue,
						   beacon.minor.intValue];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"proximity:%@, accuracy=%.2fm, RSSI:%-4d",
								 cellSetting[@"proximity"],
								 beacon.accuracy,
								 (int)beacon.rssi];
	cell.backgroundColor = cellSetting[@"cellColor"];

	return cell;
}

#pragma mark - NSNotificationCenter notification reciever
-(void)didRangeBeacons:(NSNotification *)notification
{
		NSLog(@"%@:%@", notification.name, notification.userInfo);
		NSArray *beacons = notification.userInfo[@"beacons"];
	NSLog(@"%s, count=%d", __PRETTY_FUNCTION__, (int)beacons.count);
	
	if (self.isSortEnabled) {
		self.foundBeacons = [beacons sortedArrayUsingComparator: ^(id obj1, id obj2) {
			CLBeacon *beacon1 = obj1;
			CLBeacon *beacon2 = obj2;
			NSString *s1 = [NSString stringWithFormat:@"%06d%06d", [beacon1.major intValue], [beacon1.minor intValue]];
			NSString *s2 = [NSString stringWithFormat:@"%06d%06d", [beacon2.major intValue], [beacon2.minor intValue]];
			
			if ([s1 integerValue] > [s2 integerValue]) {
				return (NSComparisonResult)NSOrderedDescending;
			}
			
			if ([s1 integerValue] < [s2 integerValue]) {
				return (NSComparisonResult)NSOrderedAscending;
			}
			return (NSComparisonResult)NSOrderedSame;
		}];
	}
	else {
		self.foundBeacons = [NSArray arrayWithArray:beacons];
	}

	[self.tableView reloadData];
}

#pragma mark - Actions
- (IBAction)didPushSortButton:(UIButton *)sender
{
	self.sortEnabled = !self.isSortEnabled;
	sender.selected = self.isSortEnabled;
}
@end

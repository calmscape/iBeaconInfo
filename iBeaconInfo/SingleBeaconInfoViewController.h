//
//  SingleBeaconInfoViewController.h
//  iBeaconInfo
//
//  Created by Masahiro Murase on 2014/01/24.
//  Copyright (c) 2014年 calmscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLBeacon;
@interface SingleBeaconInfoViewController : UITableViewController
@property (strong, nonatomic) CLBeacon *monitoredBeaconRegion;
@end

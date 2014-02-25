//
//  RangingTableViewController.h
//  iBeaconInfo
//
//  Created by Masahiro Murase on 2013/10/28.
//  Copyright (c) 2013年 calmscape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RangingTableViewController : UITableViewController
@property (nonatomic, strong, readonly) NSArray *foundBeacons;
@end

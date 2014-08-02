//
//  xyzViewController.h
//  codeTest
//
//  Created by linchuang on 31/07/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CodeTestViewController : UITableViewController
@property (nonatomic,copy)   NSString* query;
@property (nonatomic,retain) NSNumber* distance;
-(BOOL)getVenuesForLocation:(CLLocation *)location;
@end

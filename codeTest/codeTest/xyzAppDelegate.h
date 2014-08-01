//
//  xyzAppDelegate.h
//  codeTest
//
//  Created by linchuang on 31/07/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xyzViewController.h"

@interface xyzAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) XYZViewController *rootviewController;

@end

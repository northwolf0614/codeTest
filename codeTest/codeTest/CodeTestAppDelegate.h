//
//  CodeTestAppDelegate.h
//  codeTest
//
//  Created by linchuang on 31/07/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodeTestViewController.h"

@interface CodeTestAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) CodeTestViewController *rootviewController;

@end

//
//  xyzAppDelegate.m
//  codeTest
//
//  Created by linchuang on 31/07/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//


#import "Foursquare2.h"
#import "xyzAppDelegate.h"

@implementation xyzAppDelegate
-(void)dealloc
{
    [_window release];
    [_rootviewController release];
    [_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    self.rootviewController = [[[XYZViewController alloc] init] autorelease] ;
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:self.rootviewController] autorelease];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    
    //[Foursquare2 setupFoursquareWithClientId:@"5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT"
    //                                  secret:@"UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR"
    //                             callbackURL:@"testapp123://foursquare"];
    [Foursquare2 setupFoursquareWithClientId:@"ACAO2JPKM1MXHQJCK45IIFKRFR2ZVL0QASMCBCG5NPJQWF2G"
                                 secret:@"YZCKUYJ1WHUV2QICBXUBEILZI1DMPUIDP5SHV043O04FKBHL"
                                 callbackURL:@"codeTest://foursquare"];
    return YES;
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [Foursquare2 handleURL:url];
}

@end

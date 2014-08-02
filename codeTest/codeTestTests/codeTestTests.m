//
//  codeTestTests.m
//  codeTestTests
//
//  Created by linchuang on 31/07/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "CodeTestViewController.h"
#import "CodeTestAppDelegate.h"
#import "TestAnnotation.h"


#define reachabilityTestURL @"www.foursquare.com"


@interface codeTestTests : XCTestCase

@end

@implementation codeTestTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConnectionForWIFI
{
    Reachability* rechability=[Reachability reachabilityWithHostName:reachabilityTestURL] ;
     XCTAssertNotNil(rechability, @"reachability should not be nil");
    
    BOOL connectionStatus=[[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]!=NotReachable;
    XCTAssertTrue(connectionStatus, @"There should be a wifi connection");
    
}



- (void)testInstanceOfCodeTestViewController
 {
    CodeTestViewController* rootviewController = [[CodeTestViewController alloc] init]  ;
    XCTAssertNotNil(rootviewController, @"rootviewController should not be nil");
    
 }

-(void)testAnnotationInstance
{
    CLLocationCoordinate2D location;
    location.latitude=-33.7794230;
    location.longitude= 151.0388883;
    TestAnnotation* ann= [[TestAnnotation alloc] initWithCoordinates:location title:@"21 Karingal Avenue Carlingford NSW 2118" subTitle:@"+610288725738"];
     XCTAssertNotNil(ann, @"The annotation should not be nil");
    
    
}
- (void)testSearchNearby
{
    CodeTestViewController* codeTestController = [[CodeTestViewController alloc] init];
    codeTestController.distance=[NSNumber numberWithFloat:5000];
    codeTestController.query=@"coffee shop";
    CLLocation* location=[[CLLocation alloc] initWithLatitude:-33.7794230 longitude:151.0388883];
    BOOL searchResult=[codeTestController getVenuesForLocation:location];
    XCTAssertFalse(searchResult, @"The searchResult shall be NO because there is no ClientID and secret words");
    
    
    
}


@end

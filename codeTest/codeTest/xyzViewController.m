//
//  xyzViewController.m
//  codeTest
//
//  Created by linchuang on 31/07/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "xyzViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
#import "TestAnnotation.h"
#import "PhoneButton.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

#define indicatingWindowShowingTime 3
#define defaultDistance 3000

@interface XYZViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKMapView *mapView;
@property(strong,nonatomic) CLLocation *currentLocation;
@property(strong,nonatomic) UIWebView* phoneCallWebView;
@property (strong, nonatomic) FSVenue *selected;
@property (strong, nonatomic) NSArray *nearbyVenues;
@property (strong,nonatomic)Reachability* reachedHost;
@property(strong,nonatomic) UIAlertView* alertView;
@property(nonatomic,strong) NSNumber* distance;


@end

@implementation XYZViewController
-(void)dealloc
{
    
    self.mapView.delegate=nil;
    self.locationManager.delegate=nil;
    [_locationManager release];
    [_mapView release];
    [_phoneCallWebView release];
    [_selected release];
    [_nearbyVenues release];
    [_reachedHost release];
    [_alertView release];
    [_distance release];
    [_currentLocation release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [super dealloc];

}
-(void)networkChanged:(NSNotification *)note
{
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!=NotReachable&&[[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]==NotReachable)
    {
        //NSLog(@"connection transferred to 2G/3G mode");
        {
            MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
            [self.view addSubview:HUD];
            HUD.labelText = @"Connection transferred to 2G/3G mode. Charges may be applied!";
            HUD.mode = MBProgressHUDModeText;
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(indicatingWindowShowingTime);
            } completionBlock:^{
                [HUD removeFromSuperview];
                //[HUD release];
                //HUD = nil;
            }];
            
        }
        
    }
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]!=NotReachable)
    {
        //NSLog(@"network has been transferred to local wifi mode");
        {
            MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
            [self.view addSubview:HUD];
            HUD.labelText = @"connection tansferred to WIFI mode";
            HUD.mode = MBProgressHUDModeText;
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(indicatingWindowShowingTime);
            } completionBlock:^{
                [HUD removeFromSuperview];
                //[HUD release];
                //HUD = nil;
            }];
            
        }
        
    }
    if ([[Reachability  reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable)
    {
        {
            MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease] ;
            [self.view addSubview:HUD];
            HUD.labelText = @"connection broken";
            HUD.mode = MBProgressHUDModeText;
            [HUD showAnimated:YES whileExecutingBlock:^{
                sleep(indicatingWindowShowingTime);
            } completionBlock:^{
                [HUD removeFromSuperview];
                //[HUD release];
                //HUD = nil;
            }];
            
        }
        
    }
    
}
-(void)handlerightButtonItem:(id) sender
{
    [self.alertView show];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect= [self.view frame];
    self.title = @"Searching Map";
    self.mapView= [[[MKMapView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2)] autorelease];
    self.tableView.tableHeaderView = self.mapView;
    [[self mapView] setDelegate:self];
    self.mapView.showsUserLocation=YES;
    //self.tableView.tableFooterView = self.footer;
    self.locationManager = [[[CLLocationManager alloc]init] autorelease];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.reachedHost= [Reachability reachabilityWithHostName:@"www.foursquare.com"] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
    [[self reachedHost] startNotifier];
    
    UIBarButtonItem *rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(handlerightButtonItem:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.alertView = [[[UIAlertView alloc] initWithTitle:@"searching radius setting" message:@"searching radius(metres):" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"apply", nil] autorelease];
    self.alertView.delegate=self;
    [self.alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    self.distance=[NSNumber numberWithFloat:defaultDistance];


    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self updateRightBarButtonStatus];
    
}
- (void)removeAllAnnotationExceptOfCurrentUser {
    NSMutableArray *annForRemove = [[[NSMutableArray alloc] initWithArray:self.mapView.annotations] autorelease];
    if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:self.mapView.annotations.lastObject];
    } else {
        for (id <MKAnnotation> annot_ in self.mapView.annotations) {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    [self.mapView removeAnnotations:annForRemove];
}

- (void)proccessAnnotations {
    [self removeAllAnnotationExceptOfCurrentUser];
    
    [self.mapView addAnnotations:self.nearbyVenues];
    /*
    for (FSVenue* venue in self.nearbyVenues) {
        NSString* subtitle=nil;
        subtitle=venue.location.contact;
        NSString* tile=nil;
        tile=venue.name;
        TestAnnotation* annotation= [[TestAnnotation alloc] initWithCoordinates:venue.coordinate title:tile subTitle:subtitle];
        [self.mapView addAnnotation:annotation];
        
    }
     */

    
}

- (void)getVenuesForLocation:(CLLocation *)location radius:(NSNumber*)radius {
    
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:@"coffee shops"
                                     limit:nil
                                    intent:intentCheckin
                                    radius:radius
                                categoryId:nil
                                  callback:^(BOOL success, id result){
                                      if (success) {
                                          
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[[FSConverter alloc]init] autorelease];
                                          self.nearbyVenues = [converter convertToObjects:venues];
                                          [self.tableView reloadData];
                                          [self proccessAnnotations];
                                          
                                      }
                                      else
                                      {
                                          MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease] ;
                                          [self.view addSubview:HUD];
                                          HUD.labelText = @"Getting nearby favouriate sites fail ";
                                          HUD.mode = MBProgressHUDModeText;
                                          [HUD showAnimated:YES whileExecutingBlock:^{
                                              sleep(indicatingWindowShowingTime);
                                          } completionBlock:^{
                                              [HUD removeFromSuperview];
                                              //[HUD release];
                                              //HUD = nil;
                                          }];
                                      }
                                  }];
}

- (void)setupMapForLocatoion:(CLLocation *)newLocation
{
    
     CLLocationCoordinate2D coordinate;
     coordinate.latitude = newLocation.coordinate.latitude;
     coordinate.longitude = newLocation.coordinate.longitude;
     MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, [self.distance doubleValue]*2,[self.distance doubleValue]*2);
     MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
     [self.mapView setRegion:adjustedRegion animated:YES];
    
}


-(void)contactIsPressed:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        if ([sender isKindOfClass:[PhoneButton class]])
        {
            NSString* callNumber=[(PhoneButton*)sender phoneNumber];
            [self makeACall:callNumber];
        }
    
    
}
-(void)makeACall:(NSString*) phoneNum
{
    /* alternatively to make a call
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    if ( self.phoneCallWebView==nil) {
        self.phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        
    }
    [self.phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    */
    
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tableViewDataSourceDelegate tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nearbyVenues.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.nearbyVenues.count) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"testCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    FSVenue *venue = self.nearbyVenues[indexPath.row];
    cell.textLabel.text = [venue name];
    if ([venue.location.address isKindOfClass:[NSString class]])
        
    {
        if (![venue.location.contact isKindOfClass:[NSString class]]) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance:%@m, Address:%@",
                                         venue.location.distance,
                                         venue.location.address];

        }
        else if([venue.location.contact isKindOfClass:[NSString class]])
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance:%@m Address:%@ Phone:%@",
                                         venue.location.distance,
                                         venue.location.address,venue.location.contact];

            
           }
    else
    {
        if (![venue.location.contact isKindOfClass:[NSString class]])
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance:%@m",
                                     venue.location.distance];
        else if([venue.location.contact isKindOfClass:[NSString class]])
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance:%@m Phone:%@",
                                         venue.location.distance,
                                         venue.location.contact];
            
    }
    return cell;


}

 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
     FSVenue* venue=[[self nearbyVenues] objectAtIndex:indexPath.row];
     if ([venue.location.contact isKindOfClass:[NSString class]])
     {
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

             return YES;
         
     }
     return NO;

 }

 - (NSString *)tableView:(UITableView *)tableView
 titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     FSVenue* venue=[[self nearbyVenues] objectAtIndex:indexPath.row];
     if ([venue.location.contact isKindOfClass:[NSString class]])
     {
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
             return @"Contact";
         
     }
     return nil;

 }

 -(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     FSVenue* venue=[[self nearbyVenues] objectAtIndex:indexPath.row];
     if ([venue.location.contact isKindOfClass:[NSString class]])
     {
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
             [self makeACall:venue.location.contact];
         
     }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSVenue *venue = self.nearbyVenues[indexPath.row];
    for (TestAnnotation* an in self.mapView.annotations) {
        if ([an.title isEqual:venue.name]) {
            
            [self.mapView selectAnnotation:an animated:YES];
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta = 0.005;
            span.longitudeDelta = 0.005;
            region.span = span;
            region.center = venue.coordinate;
            [self.mapView setRegion:region animated:YES];
            self.tableView.contentOffset=CGPointZero;

        }
    }

}


#pragma CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    self.currentLocation=newLocation;
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!=NotReachable)
    {
        [self getVenuesForLocation:newLocation radius:self.distance];
    }
    
    [self setupMapForLocatoion:newLocation];
    //[self showAnnotation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease] ;
    [self.view addSubview:HUD];
    HUD.labelText = @"Getting user's location fail ";
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(indicatingWindowShowingTime);
    } completionBlock:^{
        [HUD removeFromSuperview];
        //[HUD release];
        //HUD = nil;
    }];

    [self.locationManager stopUpdatingLocation];
}

#pragma MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    if(![annotation isKindOfClass:[TestAnnotation class]])
    {
        return nil;
    }
    
    if(![mapView isEqual:self.mapView])
    {
        return nil;
    }
    
    
    TestAnnotation * senderAnnotation =nil;
    senderAnnotation=(TestAnnotation *)annotation;
    NSString * pinReusableIdentifier = @"testIdentifier";
    MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
    if(annotationView == nil)
    {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:senderAnnotation reuseIdentifier:pinReusableIdentifier] autorelease];
        [annotationView setCanShowCallout:YES];
        
    }
    
    if ([senderAnnotation.subtitle isKindOfClass:[NSString class]])
    {
        //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            PhoneButton * button = [PhoneButton buttonWithType:UIButtonTypeInfoLight];
            button.phoneNumber=senderAnnotation.subtitle;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [button addTarget:self action:@selector(contactIsPressed:) forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = button;
        }
        
    }
    
    
    annotationView.opaque = NO;
    annotationView.animatesDrop = YES;
    annotationView.draggable = NO;
    annotationView.selected = YES;
    annotationView.calloutOffset = CGPointMake(5, 5);
    return  annotationView;
   
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* radiusString=nil;
    if (buttonIndex==1)
    {
        radiusString=[[self.alertView textFieldAtIndex:0] text];
        self.distance=[NSNumber numberWithFloat:[radiusString floatValue]] ;
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!=NotReachable)
        {
            [self getVenuesForLocation:self.currentLocation radius:self.distance];
        }
        
        [self setupMapForLocatoion:self.currentLocation];
    }
    
   
    
}





@end

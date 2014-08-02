//
//  xyzViewController.m
//  codeTest
//
//  Created by linchuang on 31/07/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "CodeTestViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
#import "TestAnnotation.h"
#import "PhoneButton.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

#define indicatingWindowShowingTime         3
#define defaultDistance                     3000//in meter
#define reachabilityTestURL                 @"www.foursquare.com"
#define deltaOfLatitude                     0.005
#define deltaOfLongtitude                   0.005
#define tableCellHeight                     70
#define maxLinesInACell                      3

@interface CodeTestViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,UIAlertViewDelegate>

@property (retain,  nonatomic) CLLocationManager *locationManager;
@property (retain,  nonatomic) MKMapView *mapView;
@property (retain,  nonatomic) CLLocation *currentLocation;
//@property (retain,  nonatomic) UIWebView* phoneCallWebView;
@property (retain,  nonatomic) FSVenue *selected;
@property (retain,  nonatomic) NSArray *nearbyVenues;
@property (retain,  nonatomic) Reachability* reachedHost;
@property (retain,  nonatomic) UIAlertView* alertView;
@end

@implementation CodeTestViewController
-(void)dealloc
{
    
    self.mapView.delegate=nil;
    self.locationManager.delegate=nil;
    self.alertView.delegate=nil;
    [_locationManager release];
    [_mapView release];
    //[_phoneCallWebView release];
    [_selected release];
    [_nearbyVenues release];
    [_reachedHost release];
    [_alertView release];
    [_distance release];
    [_query release];
    [_currentLocation release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [super dealloc];

}
-(void)networkChanged:(NSNotification *)note
{
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!=NotReachable&&[[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]==NotReachable)
    {
        //connection transferred to 2G/3G mode
        {
            MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
            [self.view addSubview:HUD];
            HUD.labelText = @"Transferred to 2G/3G mode";
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
        //network has been transferred to local wifi mode
        {
            MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
            [self.view addSubview:HUD];
            HUD.labelText = @"Tansferred to WIFI mode";
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
    //not network connection
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
    //initiate tableview's header view using mapview
    CGRect rect= [self.view frame];
    self.title = @"Searching Map";
    self.mapView= [[[MKMapView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/3)] autorelease];
    self.tableView.tableHeaderView = self.mapView;
    [[self mapView] setDelegate:self];
    //show the user's location
    self.mapView.showsUserLocation=YES;
    //initiate the location manager
    self.locationManager = [[[CLLocationManager alloc]init] autorelease];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    //initiate the reachability with reachabilityTest
    self.reachedHost= [Reachability reachabilityWithHostName:reachabilityTestURL] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
    [[self reachedHost] startNotifier];
    //initiate the rightButton of navigatioinItem
    UIBarButtonItem *rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(handlerightButtonItem:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    //initiate alertview
    self.alertView = [[[UIAlertView alloc] initWithTitle:@"searching radius setting" message:@"searching radius(metres):" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"apply", nil] autorelease];
    self.alertView.delegate=self;
    [self.alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    //initiate the searching distance
    self.distance=[NSNumber numberWithFloat:defaultDistance];
    self.query=@"coffee shop";
    //if the device is ios7
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }



    
}

- (void)removeAllAnnotationExceptOfCurrentUser
{
    NSMutableArray *annForRemove = [[[NSMutableArray alloc] initWithArray:self.mapView.annotations] autorelease];
    if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]])
    {
        [annForRemove removeObject:self.mapView.annotations.lastObject];
    }
    else
    {
        for (id <MKAnnotation> annot_ in self.mapView.annotations)
        {
            if ([annot_ isKindOfClass:[MKUserLocation class]] )
            {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    [self.mapView removeAnnotations:annForRemove];
}

- (void)proccessAnnotations {
    [self removeAllAnnotationExceptOfCurrentUser];
    //add standard annotation view to map view
    //[self.mapView addAnnotations:self.nearbyVenues];
     //alternatively to add customized annotation view
    for (FSVenue* venue in self.nearbyVenues)
    {
        NSString* subtitle=nil;
        subtitle=venue.location.contact;
        NSString* tile=nil;
        tile=venue.name;
        TestAnnotation* annotation= [[TestAnnotation alloc] initWithCoordinates:venue.coordinate title:tile subTitle:subtitle];
        [self.mapView addAnnotation:annotation];
        
    }
    
    
}

- (BOOL)getVenuesForLocation:(CLLocation *)location
{
    __block BOOL searchResult=NO;
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:self.query
                                     limit:nil
                                    intent:intentCheckin
                                    radius:self.distance
                                categoryId:nil
                                  callback:^(BOOL success, id result){
                                      if (success)//This is a branch for sucess
                                      {
                                          
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[[FSConverter alloc]init] autorelease];
                                          self.nearbyVenues = [converter convertToObjects:venues];
                                          [self.tableView reloadData];
                                          [self proccessAnnotations];
                                          searchResult=YES;
                                          
                                          
                                      }
                                      else//This is a branch for failure
                                      {
                                          MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease] ;
                                          [self.view addSubview:HUD];
                                          HUD.labelText = @"Searching nearby fail ";
                                          HUD.mode = MBProgressHUDModeText;
                                          [HUD showAnimated:YES whileExecutingBlock:^{
                                              sleep(indicatingWindowShowingTime);
                                          } completionBlock:^{
                                              [HUD removeFromSuperview];
                                              //[HUD release];
                                              //HUD = nil;
                                          }];
                                          searchResult=NO;
                                          
                                      }
                                  }];
    return searchResult;
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
    /*// alternatively to make a call for future use in case the app can not pass the apple's examination
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    if ( self.phoneCallWebView==nil) {
        self.phoneCallWebView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
        
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
    if (self.nearbyVenues.count)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //reuse the table cell
    static NSString *cellIdentifier = @"testCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    cell.detailTextLabel.numberOfLines = maxLinesInACell;
    FSVenue *venue = self.nearbyVenues[indexPath.row];
    cell.textLabel.text = [venue name];
    //deal with the different cases for the address, contact
    if ([venue.location.address isKindOfClass:[NSString class]])
        
    {
        if (![venue.location.contact isKindOfClass:[NSString class]])
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance:%@m\nAddress:%@",
                                         venue.location.distance,
                                         venue.location.address];

        }
        else if([venue.location.contact isKindOfClass:[NSString class]])
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance:%@m\nAddress:%@\nPhone:%@",
                                         venue.location.distance,
                                         venue.location.address,venue.location.contact];

            
    }
    else
    {
        if (![venue.location.contact isKindOfClass:[NSString class]])
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance:%@m",
                                     venue.location.distance];
        else if([venue.location.contact isKindOfClass:[NSString class]])
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance:%@m\nPhone:%@",
                                         venue.location.distance,
                                         venue.location.contact];
            
    }
    return cell;


}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableCellHeight;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSVenue *venue = self.nearbyVenues[indexPath.row];
    for (TestAnnotation* an in self.mapView.annotations)
    {
        if (an.coordinate.latitude==venue.coordinate.latitude&&an.coordinate.longitude==venue.coordinate.longitude) {
            
            [self.mapView selectAnnotation:an animated:YES];
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta=deltaOfLatitude;
            span.longitudeDelta = deltaOfLongtitude;
            region.span = span;
            region.center = venue.coordinate;
            [self.mapView setRegion:region animated:YES];
            //make the tableview to the origianl point to make users see the map conviniently
            self.tableView.contentOffset=CGPointZero;

        }
    }

}



#pragma CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    self.currentLocation=newLocation;
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!=NotReachable)
    {
        [self getVenuesForLocation:newLocation ];
    }
    
    [self setupMapForLocatoion:newLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    MBProgressHUD* HUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease] ;
    [self.view addSubview:HUD];
    HUD.labelText = @"Gettng location fail ";
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
    else
    {
        annotationView.annotation=senderAnnotation;
        annotationView.rightCalloutAccessoryView=nil;
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
    annotationView.calloutOffset = CGPointZero;
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
            [self getVenuesForLocation:self.currentLocation ];
        }
        
        [self setupMapForLocatoion:self.currentLocation];
    }
    
}
@end

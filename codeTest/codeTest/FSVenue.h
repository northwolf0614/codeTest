

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface FSLocation : NSObject
{
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic,assign)CLLocationCoordinate2D coordinate;
@property (nonatomic,retain)NSNumber *distance;
@property (nonatomic,retain)NSString *address;
@property (nonatomic,retain)NSString* contact;

@end


@interface FSVenue : NSObject<MKAnnotation>
{
}

@property (nonatomic,retain)NSString *name;
@property (nonatomic,retain)NSString *venueId;
@property (nonatomic,retain)FSLocation *location;

@end

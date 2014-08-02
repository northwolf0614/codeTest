//
//  VenueAnnotation.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import "FSVenue.h"


@implementation FSLocation
-(void)dealloc
{
    [_distance release];
    [_address release];
    [_contact release];
    [super dealloc];
}
@end

@implementation FSVenue
-(void)dealloc
{
    [_name release];
    [_venueId release];
    [_location release];
    [super dealloc];
    
}
- (id)init {
    self = [super init];
    if (self) {
        self.location = [[[FSLocation alloc]init] autorelease];
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return self.location.coordinate;
}

- (NSString *)title {
    return self.name;
}
@end

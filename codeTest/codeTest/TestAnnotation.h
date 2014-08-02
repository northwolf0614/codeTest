//
//  TestAnnotation.h
//  codeTest
//
//  Created by linchuang on 1/08/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>



@interface TestAnnotation : NSObject <MKAnnotation>
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy,readonly) NSString * title;
@property (nonatomic,copy,readonly) NSString * subtitle;
@property (nonatomic,assign) MKPinAnnotationColor pinColor;

-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramTitle;

@end
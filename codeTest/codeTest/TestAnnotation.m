//
//  TestAnnotation.m
//  codeTest
//
//  Created by linchuang on 1/08/2014.
//  Copyright (c) 2014 codeTest. All rights reserved.
//

#import "TestAnnotation.h"

@implementation TestAnnotation
-(void)dealloc
{
    [_subtitle release];
    [_title release];
    [super dealloc];

}
-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramSubitle
{
    self = [super init];
    if(self != nil)
    {
        _coordinate = paramCoordinates;
        _title = [paramTitle copy];
        _subtitle = [paramSubitle copy];
    }
    return self;
}

@end

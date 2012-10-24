//
//  ESLocationTracker.h
//  Epom SDK
//
//  Created by Epom LTD on 10/17/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	This file is for inner usage. No documentation provided

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface ESLocationTracker : NSObject<CLLocationManagerDelegate>

+(ESLocationTracker *) shared;

-(void)setForceUseLocation:(BOOL)yesOrNo;
-(CLLocation *)currentLocation;

@end

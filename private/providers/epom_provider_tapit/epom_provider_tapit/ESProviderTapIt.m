//
//  ESProviderTapIt.m
//  ESProviderTapIt
//
//  Created by Epom LTD on 7/2/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import "ESProviderTapIt.h"

#import "EpomSettings.h"
#import "ESLogger.h"

#import <CoreLocation/CLLocation.h>

#define ZONE_ID_KEY @"ZONE_ID"

@implementation ESProviderTapIt

@synthesize tapItView;

+ (BOOL)initializeSystem
{
	return YES;
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.tapItView = [[[TapItAdMobileView alloc] initWithFrame:epom_view_size(size) zone:[params valueForKey:ZONE_ID_KEY]] autorelease];
	self.tapItView.delegate = self;
	self.tapItView.logMode = NO;//([ESLogger shared].verboseType != ESVerboseNone);
	self.tapItView.updateTimeInterval = 0.f;
	CLLocation *location = [self.delegate currentLocation];
	if (location != nil) 
	{
		self.tapItView.longitude = [NSString stringWithFormat:@"%3.6f", location.coordinate.longitude];
		self.tapItView.latitude = [NSString stringWithFormat:@"%3.6f", location.coordinate.latitude];
	}
	
	[self.tapItView update];
	
	return self;
}

- (void)dealloc
{
	self.tapItView.delegate = nil;
	self.tapItView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.tapItView;
}

#pragma mark -- delegate methods

- (void)willReceiveAd:(id)sender
{
	
}

- (void)didReceiveAd:(id)sender
{
	[self.delegate providerDidRecieveAd:self];	
}

- (void)didFailToReceiveAd:(id)sender withError:(NSError*)error
{
	ES_LOG_ERROR(@"TapIt ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (void)adWillStartFullScreen:(id)sender
{
	[self.delegate providerViewHasBeenClicked:self];
	
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void)adDidEndFullScreen:(id)sender
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

- (BOOL)adShouldOpen:(id)sender withUrl:(NSURL*)url
{
	[self.delegate providerViewHasBeenClicked:self];
	
	[self.delegate providerViewWillLeaveApplication:self];
	
	return YES;
}

@end

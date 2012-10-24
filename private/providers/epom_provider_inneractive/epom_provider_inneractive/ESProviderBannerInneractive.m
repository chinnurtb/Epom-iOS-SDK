//
//  ESProviderBannerInneractive.m
//  ESProviderBannerInneractive
//
//  Created by Epom LTD on 6/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBannerInneractive.h"

#import <UIKit/UIKit.h>

#import "EpomSettings.h"

#import "ESLocationTracker.h"

#define APPLICATION_ID_KEY @"APPLICATION_ID"

@implementation ESProviderBannerInneractive

@synthesize iaView;

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	
	
	// Optional parameters
	NSMutableDictionary *optionalParams = [[[NSMutableDictionary alloc] init] autorelease];

	CLLocation *location = [[ESLocationTracker shared] currentLocation];
	if (location != nil) 
	{
		[optionalParams setObject:[NSString stringWithFormat:@"%3.6f,%3.6f", location.coordinate.latitude, location.coordinate.longitude] 
						   forKey:[NSNumber numberWithInt:Key_Gps_Coordinates]];
	}

	self.iaView = [[[InneractiveAd alloc] initWithAppId:[params valueForKey:APPLICATION_ID_KEY]
											   withType:IaAdType_Banner
											 withReload:120
											 withParams:optionalParams] autorelease];
	self.iaView.delegate = self;
	
	return self;
}

- (void)dealloc
{	
	self.iaView.delegate = nil;
	self.iaView = nil;
	
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.iaView;
}

#pragma mark -- InneractiveAd callbacks

- (void)IaAdReceived
{
	[self.delegate providerDidRecieveAd:self];
}

- (void)IaDefaultAdReceived
{
	if ([self.delegate inTestMode])
	{
		[self.delegate providerDidRecieveAd:self];
	}
	else
	{
		// treat default ads like errors
		[self.delegate providerFailedToRecieveAd:self];
	}
}

- (void)IaAdFailed
{
	ES_LOG_ERROR(@"InnerActive ad request failed: (unknown)");
	[self.delegate providerFailedToRecieveAd:self];	
}

- (void)IaAdClicked
{
	[self.delegate providerViewHasBeenClicked:self];
}

- (void)IaAdWillShow
{
	
}

- (void)IaAdDidShow
{
	
}

- (void)IaAdWillHide
{
	
}

- (void)IaAdDidHide
{
	
}

- (void)IaAdWillClose
{
	
}

- (void)IaAdDidClose
{
	
}

- (void)IaAdWillResize
{
	
}

- (void)IaAdDidResize
{
	
}

- (void)IaAdWillExpand
{
	
}

- (void)IaAdDidExpand
{
	
}

- (void)IaAppShouldSuspend
{
	
}

- (void)IaAppShouldResume
{
	
}


@end

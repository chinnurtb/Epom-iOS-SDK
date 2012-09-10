//
//  epom_provider_admob.m
//  epom_provider_admob
//
//  Created by Epom LTD on 5/30/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderAdMob.h"

#import "GoogleAdMobAds/GADBannerView.h"

#import "EpomSettings.h"

#import <CoreLocation/CLLocation.h>

#define PUBLISHER_ID_KEY @"PUBLISHER_ID"

@implementation ESProviderAdMob

@synthesize gadView;

#pragma mark init/deinit

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}

	self.gadView = [[[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(epom_view_size(size).size)] autorelease];
	self.gadView.delegate = self;	
	self.gadView.rootViewController = [self.delegate screenPresentController];
	self.gadView.adUnitID = [params valueForKey:PUBLISHER_ID_KEY];	
	
	// request setup
	GADRequest *request = [GADRequest request];	
	request.testing = [self.delegate inTestMode];
	
	CLLocation *location = [self.delegate currentLocation];	
	if (location)
	{
		[request setLocationWithLatitude:location.coordinate.latitude 
							   longitude:location.coordinate.longitude 
								accuracy:location.horizontalAccuracy];
	}
	
	[self.gadView loadRequest:request];
		
	return self;
}

- (void)dealloc
{
	self.gadView.delegate = nil;
	self.gadView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.gadView;
}

#pragma mark -- GADBannerView delegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
	[self.delegate providerDidRecieveAd:self];
}

- (void)adView:(GADBannerView *)viewdidFailToReceiveAdWithError:(GADRequestError *)error
{
	ES_LOG_ERROR(@"AdMob ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];	
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
	[self.delegate providerViewHasBeenClicked:self];
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
	[self.delegate providerViewHasBeenClicked:self];
	[self.delegate providerViewWillLeaveApplication:self];
}

@end

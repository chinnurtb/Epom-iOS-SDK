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
	
	// create request
	// if not passing in any params:
	TapItRequest *request = nil;
	
	if ([self.delegate inTestMode])
	{
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"test", @"mode", nil];
		request = [TapItRequest requestWithAdZone:[params valueForKey:ZONE_ID_KEY] andCustomParameters:params];
	}
	else
	{
		request = [TapItRequest requestWithAdZone:[params valueForKey:ZONE_ID_KEY]];
	}
	
	self.tapItView = [[[TapItBannerAdView alloc] initWithFrame:epom_view_size(size)] autorelease];
	self.tapItView.delegate = self;
	
	self.tapItView.animated = NO;
	self.tapItView.shouldReloadAfterTap = NO;
	self.tapItView.presentingController = [self.delegate screenPresentController];

	[self.tapItView updateLocation:[self.delegate currentLocation]];
	[self.tapItView startServingAdsForRequest:request];
	
	return self;
}

- (void)dealloc
{
	[self.tapItView cancelAds];
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

- (void)tapitBannerAdViewWillLoadAd:(TapItBannerAdView *)bannerView
{
	
}

- (void)tapitBannerAdViewDidLoadAd:(TapItBannerAdView *)bannerView
{
	[self.tapItView cancelAds];
	[self.delegate providerDidRecieveAd:self];	
}

- (void)tapitBannerAdView:(TapItBannerAdView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
	[self.tapItView cancelAds];
	
	ES_LOG_ERROR(@"TapIt ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];

}

- (BOOL)tapitBannerAdViewActionShouldBegin:(TapItBannerAdView *)bannerView willLeaveApplication:(BOOL)willLeave
{
	[self.delegate providerViewHasBeenClicked:self];
	[self.delegate providerViewWillEnterModalMode:self];
	
	if (willLeave)
	{
		[self.delegate providerViewWillLeaveApplication:self];
	}
	
	return YES;
}

- (void)tapitBannerAdViewActionWillFinish:(TapItBannerAdView *)bannerView
{
	
}

- (void)tapitBannerAdViewActionDidFinish:(TapItBannerAdView *)bannerView
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

@end

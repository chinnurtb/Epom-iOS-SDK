//
//  ESProviderBannerTapIt.m
//  ESProviderBannerTapIt
//
//  Created by Epom LTD on 7/2/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import "ESProviderBannerTapIt.h"

#import "EpomSettings.h"
#import "ESLocationTracker.h"

#define ZONE_ID_KEY @"ZONE_ID"

@implementation ESProviderBannerTapIt

@synthesize tapItView;

+ (BOOL)initializeSystem
{
	return YES;
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	// create request
	// if not passing in any params:
	TapItRequest *request = nil;
	
	NSString *zoneID = [params valueForKey:ZONE_ID_KEY];
	
	if ([self.delegate inTestMode])
	{
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"test", @"mode", nil];
		request = [TapItRequest requestWithAdZone:zoneID andCustomParameters:params];
	}
	else
	{
		request = [TapItRequest requestWithAdZone:zoneID];
	}
	
	self.tapItView = [[[TapItBannerAdView alloc] initWithFrame:epom_view_size(size)] autorelease];
	self.tapItView.delegate = self;
	
	self.tapItView.animated = NO;
	self.tapItView.shouldReloadAfterTap = NO;
	self.tapItView.presentingController = [self.delegate screenPresentController];

	[self.tapItView updateLocation:[[ESLocationTracker shared] currentLocation]];
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
	
	ES_LOG_ERROR(@"TapIt banner ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];

}

- (BOOL)tapitBannerAdViewActionShouldBegin:(TapItBannerAdView *)bannerView willLeaveApplication:(BOOL)willLeave
{
	if (actionBegin == NO)
	{
		[self.delegate providerViewHasBeenClicked:self];
		[self.delegate providerViewWillEnterModalMode:self];
		actionBegin = YES;
	}
	
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
	if (actionBegin == YES)
	{
		[self.delegate providerViewDidLeaveModalMode:self];
		actionBegin = NO;
	}
}

@end

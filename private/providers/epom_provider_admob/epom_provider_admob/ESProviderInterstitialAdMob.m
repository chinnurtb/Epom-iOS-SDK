//
//  ESProviderInterstitialAdMob.m
//  ESProviderInterstitialAdMob
//
//  Created by Epom LTD on 10/18/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialAdMob.h"

#import "GoogleAdMobAds/GADInterstitial.h"

#import "EpomSettings.h"

#import "ESLocationTracker.h"

#define PUBLISHER_ID_KEY @"PUBLISHER_ID"

@implementation ESProviderInterstitialAdMob

@synthesize gadInterstitial;

- (id)initWithParameters:(NSDictionary *)params
				delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.gadInterstitial = [[[GADInterstitial alloc] init] autorelease];
	self.gadInterstitial.adUnitID = [params valueForKey:PUBLISHER_ID_KEY];
	self.gadInterstitial.delegate = self;
	
	// request setup
	GADRequest *request = [GADRequest request];
	request.testing = [self.delegate inTestMode];
	
	CLLocation *location = [[ESLocationTracker shared] currentLocation];
	if (location)
	{
		[request setLocationWithLatitude:location.coordinate.latitude
							   longitude:location.coordinate.longitude
								accuracy:location.horizontalAccuracy];
	}
	
	[self.gadInterstitial loadRequest:request];
		
	return self;
}

- (void)dealloc
{
	self.gadInterstitial.delegate = nil;
	self.gadInterstitial = nil;
	
	[super dealloc];
}

- (void)presentWithViewController:(UIViewController *)viewController
{
	[self.gadInterstitial presentFromRootViewController:viewController];
}

#pragma mark -- GADInterstitialDelegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
	[self.delegate providerDidRecieveAd:self];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
	ES_LOG_ERROR(@"AdMob Interstitial ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

#pragma mark Display-Time Lifecycle Notifications

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
	[self.delegate providerViewDidLeaveModalMode:self];	
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:YES];
}


@end

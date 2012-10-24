//
//  ESProviderimInterstitialInMobi.m
//  ESProviderIMAdInterstitialInMobi
//
//  Created by Epom LTD on 10/18/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialInMobi.h"

#import "InMobi/IMAdInterstitial.h"

#import "EpomSettings.h"

#import "ESLocationTracker.h"

#define APPLICATION_ID_KEY	@"APPLICATION_ID"
#define SLOT_ID_KEY	@"SLOT_ID"

@implementation ESProviderInterstitialInMobi

@synthesize imInterstitial;

- (id)initWithParameters:(NSDictionary *)params
				delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}

	NSNumber *slotId = [params valueForKey:SLOT_ID_KEY];

	self.imInterstitial = [[[IMAdInterstitial alloc] init] autorelease];
	self.imInterstitial.imAppId = [params valueForKey:APPLICATION_ID_KEY];
	self.imInterstitial.imSlotId = [slotId longLongValue];
	self.imInterstitial.delegate = self;
	
	CLLocation *location = [[ESLocationTracker shared] currentLocation];
	
	IMAdRequest *request = [IMAdRequest request];
	request.testMode = [self.delegate inTestMode];
	
	if (location != nil)
	{
		[request setLocationWithLatitude:location.coordinate.latitude
							   longitude:location.coordinate.longitude
								accuracy:location.horizontalAccuracy];
	}
	
	[self.imInterstitial loadRequest:request];
	
	return self;
}

- (void)dealloc
{
	self.imInterstitial.delegate = nil;
	self.imInterstitial = nil;
	
	[super dealloc];
}

- (void)presentWithViewController:(UIViewController *)viewController
{
	[self.imInterstitial presentFromRootViewController:viewController animated:YES];
}


#pragma mark --IMAdInterstitialDelegate implementation

- (void)interstitialDidFinishRequest:(IMAdInterstitial *)ad
{
	[self.delegate providerDidRecieveAd:self];
}

- (void)interstitial:(IMAdInterstitial *)ad didFailToReceiveAdWithError:(IMAdError *)error
{
	ES_LOG_ERROR(@"InMobi Interstitial ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (void)interstitialWillPresentScreen:(IMAdInterstitial *)ad
{
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void)interstitial:(IMAdInterstitial *)ad didFailToPresentScreenWithError:(IMAdError *)error
{
	
}

- (void)interstitialWillDismissScreen:(IMAdInterstitial *)ad
{
	
}

- (void)interstitialDidDismissScreen:(IMAdInterstitial *)ad
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

- (void)interstitialWillLeaveApplication:(IMAdInterstitial *)ad
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:YES];
}


@end

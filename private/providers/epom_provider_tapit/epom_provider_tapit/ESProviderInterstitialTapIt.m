//
//  ESProviderInterstitialTapIt.m
//  ESProviderInterstitialTapIt
//
//  Created by Epom LTD on 7/2/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import "ESProviderInterstitialTapIt.h"

#import "EpomSettings.h"
#import "ESLocationTracker.h"

#define ZONE_ID_KEY @"ZONE_ID"

@implementation ESProviderInterstitialTapIt

@synthesize tapItView;

+ (BOOL)initializeSystem
{
	return YES;
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	// create request
	// if not passing in any params:
	TapItRequest *request = nil;
	
	NSString *zoneID = [params valueForKey:ZONE_ID_KEY];
	if (zoneID == nil)
	{
		zoneID = @"4670";
	}
	
	if ([self.delegate inTestMode])
	{
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"test", @"mode", nil];
		request = [TapItRequest requestWithAdZone:zoneID andCustomParameters:params];
	}
	else
	{
		request = [TapItRequest requestWithAdZone:zoneID];
	}
	self.tapItView = [[[TapItInterstitialAd alloc] init] autorelease];
	self.tapItView.delegate = self; // notify me of the interstitial's state changes

	[self.tapItView loadInterstitialForRequest:request];
	
	return self;
}

- (void)dealloc
{
	self.tapItView.delegate = nil;
	self.tapItView = nil;
	[super dealloc];
}

- (void) presentWithViewController:(UIViewController *)viewController
{
	[self.tapItView presentFromViewController:viewController];
	
	[self.delegate providerViewWillEnterModalMode:self];
}

#pragma mark -- delegate methods

- (void)tapitInterstitialAd:(TapItInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
	ES_LOG_ERROR(@"TapIt banner ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (void)tapitInterstitialAdDidUnload:(TapItInterstitialAd *)interstitialAd
{
	
}

- (void)tapitInterstitialAdWillLoad:(TapItInterstitialAd *)interstitialAd
{
	
}

- (void)tapitInterstitialAdDidLoad:(TapItInterstitialAd *)interstitialAd
{
	[self.delegate providerDidRecieveAd:self];
}

- (BOOL)tapitInterstitialAdActionShouldBegin:(TapItInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:willLeave];
	
	return YES;
}

- (void)tapitInterstitialAdActionWillFinish:(TapItInterstitialAd *)interstitialAd
{
	
}

- (void)tapitInterstitialAdActionDidFinish:(TapItInterstitialAd *)interstitialAd
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

@end

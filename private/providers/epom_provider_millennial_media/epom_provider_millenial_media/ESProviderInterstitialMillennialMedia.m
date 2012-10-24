//
//  ESProviderInterstitialMillenialMedia.m
//  ESProviderInterstitialMillenialMedia
//
//  Created by Epom LTD on 10/18/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialMillennialMedia.h"

#import "EpomSettings.h"
#import "ESLocationTracker.h"

#define APPLICATION_ID_KEY @"PLACEMENT_ID"


@class CLLocation;

@implementation ESProviderInterstitialMillennialMedia

@synthesize mmAdView;
@synthesize rootViewController;

+ (BOOL)initializeSystem
{
	[MMAdView setLogLevel: MMLOG_LEVEL_OFF];

	return YES;
}

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.rootViewController = [[[UIViewController alloc] init] autorelease];
	
	self.mmAdView = [MMAdView interstitialWithType:MMFullScreenAdTransition
											  apid:[params valueForKey:APPLICATION_ID_KEY]
										  delegate:self
											loadAd:YES];
	
	self.mmAdView.refreshTimerEnabled = NO;
	
	self.mmAdView.rootViewController = self.rootViewController;
		
	CLLocation *location = [[ESLocationTracker shared] currentLocation];
	
	if (location != nil)
	{
		[MMAdView updateLocation:location];
	}
	
	return self;
}

- (void)dealloc
{
	
	self.mmAdView.delegate = nil;
	self.mmAdView = nil;
	
	self.rootViewController = nil;
	
	[super dealloc];
}

- (void)presentWithViewController:(UIViewController *)viewController
{
	[viewController presentModalViewController:self.rootViewController animated:NO];
	[self.delegate providerViewWillEnterModalMode:self];
}

#pragma mark -- delegate methods

- (NSDictionary *)requestData
{
	return nil;
}

// Set the timer duration for the rotation of ads in seconds. Default: 60
- (NSInteger)adRefreshDuration
{
	return 60000; // no autorefresh
}

- (BOOL)accelerometerEnabled
{
	return NO;
}

- (void)adRequestSucceeded:(MMAdView *) adView
{
	[self.delegate providerDidRecieveAd:self];	
}

- (void)adRequestFailed:(MMAdView *) adView
{
	ES_LOG_ERROR(@"MillennialMedia interstitial ad request failed: (unknown)");
	[self.delegate providerFailedToRecieveAd:self];
}

- (void)adDidRefresh:(MMAdView *) adView
{
	
}

- (void)adWasTapped:(MMAdView *) adView
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:NO];
}

- (void)adRequestIsCaching:(MMAdView *) adView
{
	
}

- (void)adRequestFinishedCaching:(MMAdView *) adView successful: (BOOL) didSucceed
{
	
}

- (void)applicationWillTerminateFromAd
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:YES];
}

- (void)adModalWillAppear
{
}

- (void)adModalDidAppear
{
	
}

- (void)adModalWasDismissed
{
	[self.rootViewController dismissModalViewControllerAnimated:NO];
	[self.delegate providerViewDidLeaveModalMode:self];
}

@end

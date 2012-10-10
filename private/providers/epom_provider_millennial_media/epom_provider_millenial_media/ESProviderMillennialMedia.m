//
//  ESProviderMillenialMedia.m
//  ESProviderMillenialMedia
//
//  Created by Epom LTD on 6/6/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderMillennialMedia.h"

#import "EpomSettings.h"

#define APPLICATION_ID_KEY @"PLACEMENT_ID"


@class CLLocation;

@implementation ESProviderMillennialMedia

@synthesize mmAdView;

+ (BOOL)initializeSystem
{
	[MMAdView setLogLevel: MMLOG_LEVEL_OFF];

	return YES;
}

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
		
	CGRect sizes[] =
	{
		/*ESViewSize320x50	*/	CGRectMake(0, 0, 320, 53),
		/*ESViewSize768x90	*/	CGRectMake(0, 0, 768, 90),		
	};
	
	self.mmAdView = [MMAdView adWithFrame:sizes[size]
									 type:MMBannerAdTop 
									 apid:[params valueForKey:APPLICATION_ID_KEY]
								 delegate:self
								   loadAd:NO
							   startTimer:NO];
	
	self.mmAdView.refreshTimerEnabled = NO;
	self.mmAdView.rootViewController = [self.delegate screenPresentController];
		
	CLLocation *location = [self.delegate currentLocation];
	
	if (location != nil)
	{
		[MMAdView updateLocation:location];
	}
	
	[self.mmAdView refreshAd];
	
	return self;
}

- (void)dealloc
{
	self.mmAdView.delegate = nil;
	self.mmAdView = nil;
	
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return mmAdView;
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
	ES_LOG_ERROR(@"MillennialMedia ad request failed: (unknown)");
	[self.delegate providerFailedToRecieveAd:self];
}

- (void)adDidRefresh:(MMAdView *) adView
{
	
}

- (void)adWasTapped:(MMAdView *) adView
{
	[self.delegate providerViewHasBeenClicked:self];
}

- (void)adRequestIsCaching:(MMAdView *) adView
{
	
}

- (void)adRequestFinishedCaching:(MMAdView *) adView successful: (BOOL) didSucceed
{
	
}

- (void)applicationWillTerminateFromAd
{
	[self.delegate providerViewWillLeaveApplication:self];
}

- (void)adModalWillAppear
{
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void)adModalDidAppear
{
	
}

- (void)adModalWasDismissed
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

@end

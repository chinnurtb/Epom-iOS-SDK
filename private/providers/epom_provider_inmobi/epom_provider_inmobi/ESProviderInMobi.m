//
//  ESProviderInMobi.m
//  ESProviderInMobi
//
//  Created by Epom LTD on 6/1/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInMobi.h"

#import "EpomSettings.h"

#import "InMobi/IMAdView.h"
#import "InMobi/IMSDKUtil.h"

#define APPLICATION_ID_KEY	@"APPLICATION_ID"

@implementation ESProviderInMobi

@synthesize imView;

+(BOOL)initializeSystem
{
	[[IMSDKUtil util] setLogLevel:IMLogLevelMinimal];
	return YES;
}

#pragma mark init/deinit

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	UInt32 units[] = 
	{
		/*ESViewSize320x50	*/	IM_UNIT_320x50,
		/*ESViewSize768x90	*/	IM_UNIT_728x90,
	};
	
	CGRect sizes[] =
	{
		/*ESViewSize320x50	*/	CGRectMake(0, 0, 320, 50),
		/*ESViewSize768x90	*/	CGRectMake(0, 0, 728, 90),		
	};
	
	STATIC_ASSERT(ARRAY_SIZE(units) == ESViewSizeTypeCount, INVALID_UNITS_ARRAY_SIZE);
	
	self.imView = [[[IMAdView alloc]
							initWithFrame:sizes[size]
							imAppId:[params valueForKey:APPLICATION_ID_KEY]
							imAdUnit:units[size]
							rootViewController:nil] autorelease];
	self.imView.rootViewController = [self.delegate screenPresentController];
	self.imView.refreshInterval = REFRESH_INTERVAL_OFF;
	self.imView.delegate = self;


	IMAdRequest *request = [IMAdRequest request];
	request.testMode = [self.delegate inTestMode];
	request.location = [self.delegate currentLocation];
	
	[self.imView loadIMAdRequest:request];
	
	return self;
}

- (void)dealloc
{
	self.imView.delegate = nil;
	self.imView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.imView;
}

#pragma mark -- IMAdView delegate

- (void)adViewDidFinishRequest:(IMAdView *)adView
{
	[self.delegate providerDidRecieveAd:self];
}

- (void)adView:(IMAdView *)view didFailRequestWithError:(IMAdError *)error
{
	ES_LOG_ERROR(@"InMobi ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (void)adViewWillPresentScreen:(IMAdView *)adView
{
	[self.delegate providerViewHasBeenClicked:self];

	[self.delegate providerViewWillEnterModalMode:self];	
}

- (void)adViewWillDismissScreen:(IMAdView *)adView
{
	
}

- (void)adViewDidDismissScreen:(IMAdView *)adView
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

- (void)adViewWillLeaveApplication:(IMAdView *)adView
{
	[self.delegate providerViewHasBeenClicked:self];	
	[self.delegate providerViewWillLeaveApplication:self];
}

@end

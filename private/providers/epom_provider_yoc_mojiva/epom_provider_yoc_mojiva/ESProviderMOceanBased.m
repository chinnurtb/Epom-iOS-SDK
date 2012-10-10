//
//  ESProviderMOceanBased.m
//  ESProviderMOceanBased
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderMOceanBased.h"

#import "mOcean/Classes/Public/MASTAdView.h"

#import "EpomSettings.h"

#import <CoreLocation/CLLocation.h>

#define SITE_ID_KEY @"SITE_ID"
#define ZONE_ID_KEY @"ZONE_ID"

#define REQUIRED_IOS_VERSION @"4.2"

@implementation ESProviderMOceanBased

@synthesize mastView;

#pragma mark init/deinit

+ (BOOL)initializeSystem
{
	NSString *reqSysVer = REQUIRED_IOS_VERSION;
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL result = [currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending;
	
	return result;
}

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	// dummy values from sample
	NSInteger site = 0;
    NSInteger zone = 0;
	
	if ([params valueForKey:SITE_ID_KEY])
	{
		site = [[params valueForKey:SITE_ID_KEY] intValue];
	}
	
	if ([params valueForKey:ZONE_ID_KEY])
	{
		zone = [[params valueForKey:ZONE_ID_KEY] intValue];
	}
	
	self.mastView = [[[MASTAdView alloc] initWithFrame:epom_view_size(size) site:site zone:zone] autorelease];
	self.mastView.delegate = self;
	
	CLLocation *location = [self.delegate currentLocation];
	if (location != nil)
	{
		self.mastView.longitude = [NSString stringWithFormat:@"%3.6f", location.coordinate.longitude];
		self.mastView.latitude = [NSString stringWithFormat:@"%3.6f", location.coordinate.latitude];
	}
	
	self.mastView.testMode = [self.delegate inTestMode];
	self.mastView.type = AdTypeRichmediaAndImages;
	self.mastView.internalOpenMode = YES;
	self.mastView.logMode = AdLogModeNone;
	self.mastView.adServerUrl = [self adServerURL];
	[self.mastView update];
	
	return self;
}

- (void)dealloc
{
	self.mastView.delegate = nil;
	self.mastView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.mastView;
}

- (NSString *)adServerURL
{
	assert(false);
	return nil;
}

- (NSString *)adNetworkName
{
	assert(false);
	
	return nil;
}

#pragma mark -- MASTAdViewDelegate

- (void)willReceiveAd:(id)sender
{
	
}

- (void)didReceiveAd:(id)sender
{
	NSObject *dlgt = self.delegate;
	[dlgt performSelectorOnMainThread:@selector(providerDidRecieveAd:) withObject:self waitUntilDone:NO];
}

- (void)didReceiveThirdPartyRequest:(id)sender content:(NSDictionary*)content
{
	
}

- (void)didFailToReceiveAd:(id)sender withError:(NSError*)error
{
	ES_LOG_ERROR(@"%@ ad request failed: %@", [self adNetworkName], error);
	
	NSObject *dlgt = self.delegate;
	[dlgt performSelectorOnMainThread:@selector(providerFailedToRecieveAd:) withObject:self waitUntilDone:NO];
}

- (void)adWillStartFullScreen:(id)sender
{
	NSObject *dlgt = self.delegate;
	[dlgt performSelectorOnMainThread:@selector(providerViewWillEnterModalMode:) withObject:self waitUntilDone:NO];
}

- (void)adDidEndFullScreen:(id)sender
{
	NSObject *dlgt = self.delegate;
	[dlgt performSelectorOnMainThread:@selector(providerViewDidLeaveModalMode:) withObject:self waitUntilDone:NO];
}


- (BOOL)adShouldOpen:(id)sender withUrl:(NSURL*)url
{
	NSObject *dlgt = self.delegate;
	[dlgt performSelectorOnMainThread:@selector(providerViewHasBeenClicked:) withObject:self waitUntilDone:NO];
	return YES;
}

- (void)didClosedAd:(id)sender usageTimeInterval:(NSTimeInterval)usageTimeInterval
{
	
}

- (void)ormmaProcess:(id)sender event:(NSString*)event parameters:(NSDictionary*)parameters
{
	
}

@end

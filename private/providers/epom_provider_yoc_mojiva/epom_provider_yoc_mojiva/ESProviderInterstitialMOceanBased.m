//
//  ESProviderInterstitialMOceanBased.m
//  ESProviderInterstitialMOceanBased
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialMOceanBased.h"

#import "mOcean/Classes/Public/MASTAdView.h"

#import "EpomSettings.h"

#import "ESLocationTracker.h"

#define SITE_ID_KEY @"SITE_ID"
#define ZONE_ID_KEY @"ZONE_ID"

#define REQUIRED_IOS_VERSION @"4.2"

@implementation ESProviderInterstitialMOceanBased

@synthesize mastView;

#pragma mark init/deinit

+ (BOOL)initializeSystem
{
	NSString *reqSysVer = REQUIRED_IOS_VERSION;
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL result = [currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending;
	
	return result;
}

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.parentController = [[[UIViewController alloc] init] autorelease];
	
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
	
	CGRect rect = epom_screen_size();
	
	self.mastView = [[[MASTAdView alloc] initWithFrame:rect site:site zone:zone] autorelease];
	self.mastView.delegate = self;
	
	CLLocation *location = [[ESLocationTracker shared] currentLocation];
	if (location != nil)
	{
		self.mastView.longitude = [NSString stringWithFormat:@"%3.6f", location.coordinate.longitude];
		self.mastView.latitude = [NSString stringWithFormat:@"%3.6f", location.coordinate.latitude];
	}
	
	self.mastView.testMode = [self.delegate inTestMode];
	self.mastView.type = AdTypeRichmediaAndImages;
	self.mastView.internalOpenMode = NO;
	self.mastView.logMode = AdLogModeNone;
	self.mastView.adServerUrl = [self adServerURL];
	
	self.parentController.view = self.mastView;
	self.mastView.showCloseButtonTime = 0;
	self.mastView.autocloseInterstitialTime = -1;

	[self.mastView update];
	
	return self;
}

- (void)dealloc
{
	self.parentController.view = nil;
	self.parentController = nil;
	self.mastView.delegate = nil;
	self.mastView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

 - (void)presentWithViewController:(UIViewController *)viewController
{
	[viewController presentModalViewController:self.parentController animated:YES];
	
	[self.delegate providerViewWillEnterModalMode:self];
}

- (NSString *)adServerURL
{
	NOENTRY;
	return nil;
}

- (NSString *)adNetworkName
{
	NOENTRY;
	
	return nil;
}

- (void)onUserClick
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:YES];
}

-(void)onAdClose
{
	[self.parentController dismissModalViewControllerAnimated:NO];
	[self.delegate providerViewDidLeaveModalMode:self];
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
	ES_LOG_ERROR(@"%@ interstitial ad request failed: %@", [self adNetworkName], error);
	
	NSObject *dlgt = self.delegate;
	[dlgt performSelectorOnMainThread:@selector(providerFailedToRecieveAd:) withObject:self waitUntilDone:NO];
}

- (void)adWillStartFullScreen:(id)sender
{
}

- (void)adDidEndFullScreen:(id)sender
{
}


- (BOOL)adShouldOpen:(id)sender withUrl:(NSURL*)url
{
	[self performSelectorOnMainThread:@selector(onUserClick) withObject:nil waitUntilDone:NO];
	return YES;
}

- (void)didClosedAd:(id)sender usageTimeInterval:(NSTimeInterval)usageTimeInterval
{
	[self performSelectorOnMainThread:@selector(onAdClose) withObject:nil waitUntilDone:NO];
}

- (void)ormmaProcess:(id)sender event:(NSString*)event parameters:(NSDictionary*)parameters
{
	
}

@end

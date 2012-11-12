//
//  ESProviderInterstitialSmaato.m
//  ESProviderInterstitialSmaato
//
//  Created by Epom LTD on 9/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialSmaato.h"

#import "iSoma/SOMAAdDimensionEnum.h"

#import "EpomSettings.h"
#import "ESLocationTracker.h"

#define SPACE_ID_KEY @"ADSPASE_ID"
#define PUBLISHER_ID_KEY @"PUBLISHER_ID"

@interface SOMAFullScreenBannerLocal : SOMAFullScreenBanner
@property (readwrite, assign) ESProviderInterstitialSmaato *parent;
@end

@implementation SOMAFullScreenBannerLocal
@synthesize parent;

- (void)removeFromSuperview
{
	if (self.parent != nil)
	{
		[self.parent performSelector:@selector(onFullScreenBannerClose) withObject:nil];
	}
	
	[super removeFromSuperview];
}

@end


@implementation ESProviderInterstitialSmaato

@synthesize interstitialView;

+ (BOOL)initializeSystem
{
	// temporarily disabled
	return NO && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	long long spaceId = [[params valueForKey:SPACE_ID_KEY] longLongValue];
	long long publisherId = [[params valueForKey:PUBLISHER_ID_KEY] longLongValue];
	
	if (spaceId == 0)
	{
		spaceId = 65737967;
	}
	if (publisherId == 0)
	{
		publisherId = 923830920;
	}
	
	SOMAAdSettings *adSettings = [[[SOMAAdSettings alloc] init] autorelease];
	[adSettings setAdspaceId:spaceId];
	[adSettings setPublisherId:publisherId];
		
	self.parentViewController = [[[UIViewController alloc] init] autorelease];
	self.interstitialView = [[[SOMAFullScreenBannerLocal alloc] init] autorelease];
	self.interstitialView.backgroundColor = [UIColor clearColor];
	self.interstitialView.delegate = self;
	self.interstitialView.parent = self;
	self.parentViewController.view = self.interstitialView;
	[self.interstitialView addAdListener:self];
	
	[self.interstitialView setAdSettings:adSettings];

	return self;
}

- (void)dealloc
{
	self.parentViewController.view = nil;
	self.parentViewController = nil;
	self.interstitialView.delegate = nil;
	[self.interstitialView removeAdListener:self];
	self.interstitialView = nil;
	[super dealloc];
}

- (void)presentWithViewController:(UIViewController *)viewController
{
	[viewController presentModalViewController:self.parentViewController animated:YES];
	
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void)onFullScreenBannerClose
{
	self.interstitialView.parent = nil;
	
	[self.parentViewController dismissModalViewControllerAnimated:NO];	
	[self.delegate providerViewDidLeaveModalMode:self];	
}

#pragma mark -- SOMAFullScreenBannerDelegate implementation

- (void)fullScreenBannerWillDismiss:(SOMAFullScreenBanner *)aBanner
{
	
}

- (void)fullScreenBannerDidDismiss:(SOMAFullScreenBanner *)aBanner
{
	
}

- (void)fullScreenBannerWillPresent:(SOMAFullScreenBanner *)aBanner
{
	
}

- (void)fullScreenBannerDidPresent:(SOMAFullScreenBanner *)aBanner
{
	
}

- (void)fullScreenBannerDidOpenLandingPage:(SOMAFullScreenBanner *)aBanner
{
	
}


#pragma mark -- SOMAAdListenerProtocol implementation
-(void)onReceiveAd:(id<SOMAAdDownloaderProtocol>)sender withReceivedBanner:(id<SOMAReceivedBannerProtocol>)receivedInterstitial
{
	if (receivedInterstitial.status == kSOMABannerStatusSuccess)
	{
		[self.delegate providerDidRecieveAd:self];
	}
	else
	{
		ES_LOG_ERROR(@"Smaato interstitial ad request failed. Error code 0x%x, message: %@",
					 receivedInterstitial.errorCode, receivedInterstitial.errorMessage);
		[self.delegate providerFailedToRecieveAd:self];
	}
}

@end

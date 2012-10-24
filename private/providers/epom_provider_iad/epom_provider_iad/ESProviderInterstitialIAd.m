//
//  epom_provider_iad.m
//  epom_provider_iad
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialIAd.h"

#import "UIKit/UIDevice.h"

#import "EpomSettings.h"


@implementation ESProviderInterstitialIAd

@synthesize adView;

+ (BOOL)initializeSystem
{
	return (NSClassFromString(@"ADInterstitialAd") != nil) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.adView = [[[ADInterstitialAd alloc] init] autorelease];
	self.adView.delegate = self;
	
	return self;
}

- (void)dealloc
{
	self.adView.delegate = nil;
	self.adView = nil;
	
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (void)presentWithViewController:(UIViewController *)viewController
{
	[self.adView presentFromViewController:viewController];
	
	[self.delegate providerViewWillEnterModalMode:self];
}

#pragma mark -- delegate methods

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
	
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
	ES_LOG_ERROR(@"iAd interstitial ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
	[self.delegate providerDidRecieveAd:self];
}

- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:YES];
	return YES;
	
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

@end

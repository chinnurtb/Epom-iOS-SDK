//
//  epom_provider_iad.m
//  epom_provider_iad
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBannerIAd.h"

#import "EpomSettings.h"


@implementation ESProviderBannerIAd

@synthesize adView;

+ (BOOL)initializeSystem
{
	return NSClassFromString(@"ADBannerView") != nil;
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.adView = [[[ADBannerView alloc] initWithFrame:epom_view_size(size)] autorelease];
	self.adView.delegate = self;
	
	return self;
}

- (void)dealloc
{
	[self.adView cancelBannerViewAction];
	
	self.adView.delegate = nil;
	self.adView = nil;
	
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.adView;
}

#pragma mark -- delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	[self.delegate providerDidRecieveAd:self];
}


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	ES_LOG_ERROR(@"iAd banner ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	[self.delegate providerViewHasBeenClicked:self];
	
	leaveApp = willLeave;
	if (willLeave)
	{
		[self.delegate providerViewWillLeaveApplication:self];
	}
	else 
	{
		[self.delegate providerViewWillEnterModalMode:self];	
	}
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	if (leaveApp == NO)
	{
		[self.delegate providerViewDidLeaveModalMode:self];		
	}
	leaveApp = NO;
}

@end

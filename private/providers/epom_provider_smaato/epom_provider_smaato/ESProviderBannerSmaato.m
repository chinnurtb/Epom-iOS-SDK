//
//  ESProviderBannerSmaato.m
//  ESProviderBannerSmaato
//
//  Created by Epom LTD on 9/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBannerSmaato.h"

#import "iSoma/SOMAAdDimensionEnum.h"

#import "EpomSettings.h"
#import "ESLocationTracker.h"

#define SPACE_ID_KEY @"ADSPASE_ID"
#define PUBLISHER_ID_KEY @"PUBLISHER_ID"

@implementation ESProviderBannerSmaato

@synthesize bannerView;

+ (BOOL)initializeSystem
{
	return YES;
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	SOMAAdDimension dimensions[] =
	{
		/*ESBannerViewSize320x50*/	kSOMAAdDimensionDefault,
		/*ESBannerViewSize768x90*/	kSOMAAdDimensionLeaderboard,
	};
	
	STATIC_ASSERT(ARRAY_SIZE(dimensions) == ESBannerViewSizeTypeCount, INVALID_UNITS_ARRAY_SIZE);
	
	self.bannerView = [[[SOMABannerView alloc] initWithDimension:dimensions[size]] autorelease];
	self.bannerView.backgroundColor = [UIColor clearColor];
	self.bannerView.delegate = self;
	
	int spaceId = [[params valueForKey:SPACE_ID_KEY] intValue];
	int publisherId = [[params valueForKey:PUBLISHER_ID_KEY] intValue];
	
	// test section
	if (spaceId == 0)
	{
		spaceId = 65737967;
	}
	if (publisherId == 0)
	{
		publisherId = 923830920;
	}
	//~test section
	
    self.bannerView.adSettings.adspaceId = spaceId;
    self.bannerView.adSettings.publisherId = publisherId;
	
    self.bannerView.adSettings.adType = kSOMAAdTypeAll;
	
    [self.bannerView addAdListener:self];
    [self.bannerView setLocationUpdateEnabled:([[ESLocationTracker shared] currentLocation] != nil)];
	
	[self.bannerView asyncLoadNewBanner];
	
	
	return self;
}

- (void)dealloc
{
	self.bannerView.delegate = nil;
	[self.bannerView removeAdListener:self];
	self.bannerView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.bannerView;
}

#pragma mark -- SOMABannerViewDelegate implementation

- (void)landingPageWillBeDisplayed
{
	[self.delegate providerViewHasBeenClicked:self];
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void)landingPageHasBeenClosed
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

#pragma mark -- SOMAAdListenerProtocol implementation
-(void)onReceiveAd:(id<SOMAAdDownloaderProtocol>)sender withReceivedBanner:(id<SOMAReceivedBannerProtocol>)receivedBanner
{
	if (receivedBanner.status == kSOMABannerStatusSuccess)
	{
		[self.delegate providerDidRecieveAd:self];
	}
	else
	{
		ES_LOG_ERROR(@"Smaato banner ad request failed. Error code 0x%x, message: %@",
					 receivedBanner.errorCode, receivedBanner.errorMessage);
		[self.delegate providerFailedToRecieveAd:self];
	}
}

@end

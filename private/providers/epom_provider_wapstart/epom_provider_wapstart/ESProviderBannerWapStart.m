//
//  ESProviderWapStart.m
//  ESProviderWapStart
//
//  Created by Epom LTD on 8/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESPRoviderBannerWapStart.h"

#import "WapStart/src/WPBannerRequestInfo.h"

#import "EpomSettings.h"
#import "ESLocationTracker.h"

#define APPLICATION_ID_KEY @"APPLICATION_ID"

@implementation ESProviderBannerWapStart

@synthesize wpView;

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
	NSInteger applicationID = [[params valueForKey:APPLICATION_ID_KEY] intValue];
	
	WPBannerRequestInfo *requestInfo = [[[WPBannerRequestInfo alloc] initWithApplicationId: applicationID] autorelease];
	requestInfo.location = [[ESLocationTracker shared] currentLocation];
	
	self.wpView = [[[WPBannerView alloc] initWithBannerRequestInfo:requestInfo] autorelease];
	self.wpView.frame = epom_view_size(size);
	self.wpView.disableAutoDetectLocation = YES;
	self.wpView.showCloseButton = NO;
	self.wpView.autoupdateTimeout = 0;
	self.wpView.delegate = self;
	self.wpView.hidden = NO;
	[self.wpView reloadBanner];
	
	return self;
}

- (void)dealloc
{
	self.wpView.delegate = nil;
	self.wpView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.wpView;
}

#pragma mark -- delegate methods

- (void) bannerViewPressed:(WPBannerView *)bannerView
{
	[self.delegate providerViewHasBeenClicked:self];
	[self.delegate providerViewWillLeaveApplication:self];
}

- (void) bannerViewInfoLoaded:(WPBannerView *) bannerView
{
	[self.delegate providerDidRecieveAd:self];	
}

- (void) bannerViewInfoLoadFailed:(WPBannerView *)bannerView withErrorCode:(WPBannerInfoLoaderErrorCode)errorCode
{
	ES_LOG_ERROR(@"WapStart ad request failed. Error code 0x%x", errorCode);
	
	[self.delegate providerFailedToRecieveAd:self];
}

@end

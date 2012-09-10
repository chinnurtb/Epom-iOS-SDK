//
//  ESProviderWapStart.m
//  ESProviderWapStart
//
//  Created by Epom LTD on 8/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESPRoviderWapStart.h"

#import "WapStart/src/WPBannerRequestInfo.h"
#import "WapStart/src/WPBannerInfo.h"

#import "EpomSettings.h"
#import "ESLogger.h"

#define APPLICATION_ID_KEY @"APPLICATION_ID"

@implementation ESProviderWapStart

@synthesize wpView;

+ (BOOL)initializeSystem
{
	return YES;
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	NSInteger applicationID = [[params valueForKey:APPLICATION_ID_KEY] intValue];
	
	WPBannerRequestInfo *requestInfo = [[[WPBannerRequestInfo alloc] initWithApplicationId: applicationID] autorelease];
	requestInfo.location = [self.delegate currentLocation];
	
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
	
	if (bannerView.bannerInfo.responseType == WPBannerResponseWebSite)
	{
		if (([bannerView.bannerInfo.link rangeOfString:@"itunes://"].location != NSNotFound) ||
			([bannerView.bannerInfo.link rangeOfString:@"http://itunes.apple.com"].location != NSNotFound))
		{
			// app links to itunes
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:bannerView.bannerInfo.link]];
		}
		else
		{
			ESContentWebViewController *webViewController = [[[ESContentWebViewController alloc] initWithControls] autorelease];
			webViewController.delegate = self;
			
			[self.delegate providerViewWillEnterModalMode:self];
			[[self.delegate screenPresentController] presentModalViewController:webViewController animated:YES];
			
			[webViewController loadBrowser: [NSURL URLWithString:bannerView.bannerInfo.link]];
		}		
	}
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

#pragma mark -- ESContentWebViewController delegate

- (void) onDismissWebView:(BOOL)leaveApp
{
	[self.delegate providerViewDidLeaveModalMode:self];
	
	if (leaveApp)
	{
		[self.delegate providerViewWillLeaveApplication:self];
	}
}

@end

//
//  ESProviderContent.m
//  Epom SDK
//
//  Created by Epom LTD on 6/1/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderContent.h"

#import "EpomSettings.h"

#import <UIKit/UIWebView.h>
#import <UIKit/UIScrollView.h>
#import <UIKit/UIApplication.h>

@implementation ESProviderContent

@synthesize bannerView;

#pragma mark init/deinit

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	CGRect sizes[] =
	{
		/*ESViewSize320x50	*/	CGRectMake(0, 0, 320, 50),
		/*ESViewSize768x90	*/	CGRectMake(0, 0, 728, 90),		
	};
	
	self.bannerView = [[[ESContentBannerView alloc] initWithFrame:sizes[size] modalViewController:[self.delegate screenPresentController]] autorelease];
	self.bannerView.bannerViewDelegate = self;
	
	[self.bannerView loadContent:[params valueForKey:ADNETWORK_CONTENT_KEY]];
					
	return self;
}

- (void)dealloc
{
	self.bannerView.bannerViewDelegate = nil;
	self.bannerView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.bannerView;
}

#pragma mark -- ESContentBannerViewDelegate implementation

- (CLLocation *)geoLocation
{
	return [self.delegate currentLocation];
}

- (void)didRecieveAd
{
	[self.delegate providerDidRecieveAd:self];
}

- (void)didFailToRecieveAdWithError:(NSError *)error
{
	ES_LOG_ERROR(@"Content provider failed to recieve an ad with error: %@", error);
	
	[self.delegate providerFailedToRecieveAd:self];
}

- (void)willEnterModalMode
{
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void)didLeaveModalMode
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

- (void)willLeaveApplication
{
	[self.delegate providerViewWillLeaveApplication:self];
}

- (void)hasBeenTapped
{
	[self.delegate providerViewHasBeenClicked:self];
}

@end

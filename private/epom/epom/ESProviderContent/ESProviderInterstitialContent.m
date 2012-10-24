//
//  ESProviderInterstitialContent.m
//  Epom SDK
//
//  Created by Epom LTD on 6/1/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialContent.h"

#import "EpomSettings.h"

#import <UIKit/UIWebView.h>
#import <UIKit/UIScrollView.h>
#import <UIKit/UIApplication.h>

@implementation ESProviderInterstitialContent

@synthesize interstitialView;

#pragma mark init/deinit

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.interstitialView = [[[ESContentInterstitialView alloc] init] autorelease];
	self.interstitialView.interstitialViewDelegate = self;
	
	[self.interstitialView loadContent:[params valueForKey:ADNETWORK_CONTENT_KEY]];
					
	return self;
}

- (void)dealloc
{
	self.interstitialView.interstitialViewDelegate = nil;
	self.interstitialView = nil;
	[super dealloc];
}

- (void)presentWithViewController:(UIViewController *)viewController
{
	[self.interstitialView presentWithModalViewController:viewController];
}

#pragma mark -- ESContentInterstitialViewDelegate implementation

- (void)didRecieveAd
{
	[self.delegate providerDidRecieveAd:self];
}

- (void)didFailToRecieveAdWithError:(NSError *)error
{
	ES_LOG_ERROR(@"Content provider interstitial failed to recieve an ad with error: %@", error);
	
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

- (void)didPerformUserInteraction:(BOOL)willLeaveApplication
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:willLeaveApplication];
}


@end

//
//  ESInterstitialView.m
//  Epom SDK
//
//  Created by Epom LTD on 10/16/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "epom/ESEnumerations.h"

// public interface
#import "epom/ESInterstitialView.h"

// private interface
#import "ESInterstitialView+.h"

#import "ESInterstitialInner.h"

#pragma mark --ESInterstitialView private interface

@interface ESInterstitialView()
@property (readwrite, assign) ESInterstitialInner* interstitialInner;
@end

#pragma mark --ESInterstitialView implementation

@implementation ESInterstitialView

// public properties
@synthesize delegate;
@dynamic state;
@dynamic loadTimeout;

// private properties
#pragma mark -- ESInterstitialView methods

-(id)initWithID:(NSString *)interstitialID useLocation:(BOOL)doUseLocation testMode:(BOOL)testMode
{
	self = [super init];
	if (self == nil)
	{
		return nil;
	}
	
	self.interstitialInner = [[ESInterstitialInner alloc] initWithParent:self
																	  ID:interstitialID
															 useLocation:doUseLocation
																testMode:testMode];
	
	[self.interstitialInner performSelector:@selector(reload) withObject:nil afterDelay:0.0];
	
	return self;
}

-(void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self.interstitialInner];
	
	[self.interstitialInner release];
	self.interstitialInner = nil;
	[super dealloc];
}

-(void)presentWithViewController:(UIViewController *)viewController
{
	[self.interstitialInner presentWithViewController:viewController];
}

-(void)presentAsStartupScreenWithWindow:(UIWindow *)window defaultImage:(UIImage *)image
{
	[self.interstitialInner presentAsStartupScreenWithWindow:window defaultImage:image];
}

-(void)reload
{
	[self.interstitialInner reload];
}

#pragma mark -- ESInterstitialView properties accessors
-(ESInterstitialViewStateType)state
{
	return self.interstitialInner.state;
}

-(void)setLoadTimeout:(NSTimeInterval)loadTimeout
{
	if (loadTimeout < 0)
	{
		loadTimeout = 0;
	}
	
	if ((loadTimeout != 0.f) && (loadTimeout < INTERSTITIAL_AD_MINIMAL_TIMEOUT))
	{
		ES_LOG_ERROR(@"Interstitial ad load timeout is less than minimal (%0.f seconds). Resetting to minimal.", INTERSTITIAL_AD_MINIMAL_TIMEOUT);
		loadTimeout = INTERSTITIAL_AD_MINIMAL_TIMEOUT;
	}
	
	self.interstitialInner.loadTimeout = loadTimeout;
}

-(NSTimeInterval)loadTimeout
{
	return self.interstitialInner.loadTimeout;
}

@end

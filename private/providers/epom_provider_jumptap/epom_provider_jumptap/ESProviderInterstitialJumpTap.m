//
//  ESProviderInterstitialJumpTap.m
//  ESProviderInterstitialJumpTap
//
//  Created by Epom LTD on 10/18/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialJumpTap.h"

#import "epom/ESEnumerations.h"
#import "EpomSettings.h"
#import "ESLocationTracker.h"

#import "JTIPHONE/JumpTapAppReport.h"

#define PUBLISHER_ID_KEY 	@"PUBLISHER_ALIAS"
#define SPOT_ID_KEY 		@"AD_SPOT_ALIAS"
#define SITE_ID_KEY			@"SITE_ALIAS"

@implementation ESProviderInterstitialJumpTap

@synthesize jtView;
@synthesize publisherID;
@synthesize siteID;
@synthesize spotID;
@synthesize parentViewController;

+ (BOOL)initializeSystem
{
	[JTAdWidget initializeAdService:NO];
	
	return YES;
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	self = [super initWithParameters:params delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	if ([[ESLocationTracker shared] currentLocation] != nil)
	{
		[JTAdWidget enableLocationUse];
	}
	
	//self.parentViewController = [[[UIViewController alloc] init] autorelease];
	
	self.publisherID = [params valueForKey:PUBLISHER_ID_KEY];
	self.siteID = [params valueForKey:SITE_ID_KEY];
	self.spotID = [params valueForKey:SPOT_ID_KEY];
	
	self.jtView = [[[JTAdWidget alloc] initWithDelegate:self shouldStartLoading: NO] autorelease];
	self.jtView.refreshInterval = -1;
	
	[self.jtView refreshAd];
	
	return self;
}

- (void)dealloc
{
	self.parentViewController = nil;
	[self.jtView setDelegate:nil];
	self.jtView = nil;
	[super dealloc];
}

- (void)presentWithViewController:(UIViewController *)viewController
{
	self.parentViewController = viewController;
	[self.jtView renderAd];
}

#pragma mark -- JTAdWidgetDelegate implementation

- (NSString *) publisherId: (id) theWidget
{
	return self.publisherID;
}

- (NSString *) site: (id) theWidget
{
	return self.siteID;
}

- (NSString *) adSpot: (id) theWidget
{
	return self.spotID;
}


- (CLLocation*) location: (id) theWidget
{
	return [[ESLocationTracker shared] currentLocation];
}

- (BOOL) shouldRenderAd: (id) theWidget
{
	[self.delegate providerDidRecieveAd:self];
	return NO;
}

- (void) beginAdInteraction: (id) theWidget
{
	[self.delegate providerViewUserInteraction:self willLeaveApplication:YES];
}

- (void) endAdInteraction: (id) theWidget
{
		
}

- (BOOL) isInterstitial: (id) theWidget
{
	return YES;
}

- (void) beginDisplayingInterstitial: (id) theWidget
{
	[self.delegate providerViewWillEnterModalMode:self];
}

- (void) endDisplayingInterstitial: (id) theWidget
{
	[self.delegate providerViewDidLeaveModalMode:self];
}

- (void) adWidget: (id) theWidget didFailToShowAd: (NSError *) error
{
}

- (void) adWidget: (id) theWidget didFailToRequestAd: (NSError *) error
{
	ES_LOG_ERROR(@"JumpTap ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (UIViewController*)adViewController:(id)theWidget
{
	return self.parentViewController;
}


@end

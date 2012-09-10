//
//  ESProviderJumpTap.m
//  ESProviderJumpTap
//
//  Created by Epom LTD on 6/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderJumpTap.h"

#import "epom/ESEnumerations.h"
#import "EpomSettings.h"

#import "JTIPHONE/JumpTapAppReport.h"

#define PUBLISHER_ID_KEY 	@"PUBLISHER_ALIAS"
#define SPOT_ID_KEY 		@"AD_SPOT_ALIAS"
#define SITE_ID_KEY			@"SITE_ALIAS"

@implementation ESProviderJumpTap

@synthesize jtView;
@synthesize publisherID;
@synthesize siteID;
@synthesize spotID;

+ (BOOL)initializeSystem
{
	[JTAdWidget initializeAdService:NO];
	
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

	if ([self.delegate currentLocation] != nil)
	{
		[JTAdWidget enableLocationUse];
	}

	self.publisherID = [params valueForKey:PUBLISHER_ID_KEY];
	self.siteID = [params valueForKey:SITE_ID_KEY];
	self.spotID = [params valueForKey:SPOT_ID_KEY];

	self.jtView = [[[JTAdWidget alloc] initWithDelegate:self shouldStartLoading: YES] autorelease];
	
	CGRect sizes[] =
	{
		/*ESViewSize320x50	*/	CGRectMake(0, 0, 320, 50),
		/*ESViewSize768x90	*/	CGRectMake(0, 0, 728, 90),		
	};
	
	//[JumpTapAppReport loggingEnabled:YES];


	self.jtView.frame = sizes[size];
	self.jtView.refreshInterval = -1;
	
		
	return self;
}

- (void)dealloc
{
	[self.jtView setDelegate:nil];
	self.jtView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self.jtView;
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
	return [self.delegate currentLocation];
}

- (BOOL) shouldRenderAd: (id) theWidget
{
	[self.delegate providerDidRecieveAd:self];
	return YES;
}

- (void) beginAdInteraction: (id) theWidget
{
	[self.delegate providerViewHasBeenClicked:self];
	
	[self.delegate providerViewWillEnterModalMode:self];
	
	/*
	[self.delegate providerViewWillLeaveApplication:self];
	*/
}

- (void) endAdInteraction: (id) theWidget
{

	[self.delegate providerViewDidLeaveModalMode:self];

}

- (BOOL) isInterstitial: (id) theWidget
{
	return NO;
}

- (void) beginDisplayingInterstitial: (id) theWidget
{
	
}

- (void) endDisplayingInterstitial: (id) theWidget
{
	
}

- (void) adWidget: (id) theWidget didFailToShowAd: (NSError *) error
{	
	ES_LOG_ERROR(@"JumpTap ad show failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (void) adWidget: (id) theWidget didFailToRequestAd: (NSError *) error
{
	ES_LOG_ERROR(@"JumpTap ad request failed: %@", error);
	[self.delegate providerFailedToRecieveAd:self];
}

- (UIViewController*)adViewController:(id)theWidget
{
	return [self.delegate screenPresentController];
}


@end

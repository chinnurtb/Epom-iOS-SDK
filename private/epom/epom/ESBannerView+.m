//
//  ESBannerView.m
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

// public interface
#import "epom/ESBannerView.h"

// private interface
#import "ESBannerView+.h"

// ESBannerInner
#import "ESBannerInner.h"

// settings
#import "EpomSettings.h"

@interface ESBannerView ()
@property (readwrite, assign) ESBannerInner* bannerInner;
@end

@implementation ESBannerView

#pragma mark --properties

@synthesize delegate;
@synthesize bannerInner;

@dynamic refreshTimeInterval;

#pragma mark --initiation/dinitialization
/*
+(id)bannerViewWithID:(NSString*)ID sizeType:(ESBannerViewSizeType)size modalViewController:(UIViewController *)modalViewController
	useLocation:(BOOL)doUseLocation testMode:(BOOL)testMode verboseLevel:(ESVerboseType)verboseType
{
	ESBannerView *result = [[[ESBannerInner alloc] initWithID:ID
												   sizeType:size
										modalViewController:modalViewController
												useLocation:doUseLocation
												   testMode:testMode] autorelease];
	[ESLogger shared].verboseType = verboseType;
	
	return result;
}
*/

-(id)initWithID:(NSString*)ID sizeType:(ESBannerViewSizeType)size modalViewController:(UIViewController *)modalViewController
	useLocation:(BOOL)doUseLocation testMode:(BOOL)testMode
{
	self = [super initWithFrame:epom_view_size(size)];
	if (self == nil)
	{
		return nil;
	}
	
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.backgroundColor = [UIColor clearColor];
	
	self.bannerInner = [[ESBannerInner alloc] initWithParent:self
													   ID:ID
												 sizeType:size
									  modalViewController:modalViewController
											  useLocation:doUseLocation
												 testMode:testMode];
	
	return self;
}

-(void)dealloc
{
	[self.bannerInner release];
	
	self.delegate = nil;
	self.bannerInner = nil;
	
	[super dealloc];
}

- (NSTimeInterval)refreshTimeInterval
{
	return self.bannerInner.refreshTimeInterval;
}

- (void)setRefreshTimeInterval:(NSTimeInterval)inRefreshTimeInterval
{
	if (inRefreshTimeInterval < AD_MINIMAL_REQUEST_INTERVAL)
	{
		ES_LOG_ERROR(@"Ad refresh time interval is less than minimal (%0.f seconds). Resetting to minimal.", AD_MINIMAL_REQUEST_INTERVAL);
		inRefreshTimeInterval = AD_MINIMAL_REQUEST_INTERVAL;
	}
	self.bannerInner.refreshTimeInterval = inRefreshTimeInterval;
}

@end

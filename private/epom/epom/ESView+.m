//
//  ESView.m
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

// public interface
#import "epom/ESView.h"

// private interface
#import "ESView+.h"

// ESViewInner
#import "ESViewInner.h"

// settings
#import "EpomSettings.h"


@implementation ESView

#pragma mark --properties

@synthesize delegate;
@dynamic refreshTimeInterval;

#pragma mark --initiation/dinitialization

+(id)viewWithID:(NSString*)ID sizeType:(ESViewSizeType)size modalViewController:(UIViewController *)modalViewController 
	useLocation:(BOOL)doUseLocation testMode:(BOOL)testMode verboseLevel:(ESVerboseType)verboseType
{
	ESView *result = [[[ESViewInner alloc] initWithID:ID 
										sizeType:size 
							 modalViewController:modalViewController 
									 useLocation:doUseLocation 
										testMode:testMode] autorelease];
	[ESLogger shared].verboseType = verboseType;
	
	return result;
}

- (id)initWithSizeType:(ESViewSizeType)size
{
	if (size >= ESViewSizeTypeCount)
	{
		ES_LOG_ERROR(@"ESView is initalized with wrong size type.");
		return nil;
	}
	
	self = [super initWithFrame:epom_view_size(size)];
	
	if (nil == self)
		return nil;
	
	self.refreshTimeInterval = AD_DEFAULT_REQUEST_INTERVAL;
	
	return self;
}

-(void)dealloc
{
	self.delegate = nil;
	
	[super dealloc];
}

- (NSTimeInterval)refreshTimeInterval
{
	return refreshTimeInterval;
}

- (void)setRefreshTimeInterval:(NSTimeInterval)inRefreshTimeInterval
{
	if (inRefreshTimeInterval < AD_MINIMAL_REQUEST_INTERVAL)
	{
		ES_LOG_ERROR(@"Ad refresh time interval is less than minimal (%0.f seconds). Resetting to minimal.", AD_MINIMAL_REQUEST_INTERVAL);
		inRefreshTimeInterval = AD_MINIMAL_REQUEST_INTERVAL;
	}
	refreshTimeInterval = inRefreshTimeInterval;
}

@end

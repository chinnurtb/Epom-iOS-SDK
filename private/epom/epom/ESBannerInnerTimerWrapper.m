//
//  ESViewTimerWrapper.m
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESBannerInnerTimerWrapper.h"

#import "ESBannerInner.h"

#import "EpomSettings.h"

@interface ESBannerInnerTimerWrapper ()

@property (readwrite, retain) NSTimer *timer;

@end

@implementation ESBannerInnerTimerWrapper

@synthesize timer;

-(id)initWithESBannerInner:(ESBannerInner *)view
{
	self = [super init];
	
	if (self == nil)
	{
		return nil;
	}
	esBannerInner = view;
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:AD_UPDATE_INTERVAL target:self selector:@selector(onUpdate) userInfo:nil repeats:YES];
	
	return self;
}

-(void)dealloc
{	
	self.timer = nil;
	[super dealloc];
}

-(void)onUpdate
{
	[esBannerInner onUpdate];
}

-(void)stop
{
	[self.timer invalidate];	
}

@end

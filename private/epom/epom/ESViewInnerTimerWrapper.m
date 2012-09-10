//
//  ESViewTimerWrapper.m
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESViewInnerTimerWrapper.h"

#import "ESViewInner.h"

#import "EpomSettings.h"

@interface ESViewInnerTimerWrapper ()

@property (readwrite, retain) NSTimer *timer;

@end

@implementation ESViewInnerTimerWrapper

@synthesize timer;

-(id)initWithESViewInner:(ESViewInner *)view
{
	self = [super init];
	
	if (self == nil)
	{
		return nil;
	}
	esView = view;
	
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
	[esView onUpdate];
}

-(void)stop
{
	[self.timer invalidate];	
}

@end

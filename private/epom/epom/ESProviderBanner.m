//
//  ESProviderBanner.m
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBanner.h"

#import "EpomSettings.h"

#import "objc/runtime.h"

static UInt32 g_numAliveProviders = 0;

@implementation ESProviderBanner

@synthesize delegate;
@synthesize responseParameters;
@synthesize sizeType;
@synthesize view;

+ (id)providerBannerFromClass:(Class)cls parameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate;
{
	if ([cls instancesRespondToSelector:@selector(initWithParameters:sizeType:delegate:)] == NO)
	{
		ES_LOG_ERROR(@"ProviderBanner class [%@] does not respond to initialization selector", cls);
		
		return nil;
	}
	
	ESProviderBanner *provider = [[[cls alloc] initWithParameters:params
														 sizeType:size
														 delegate:delegate] autorelease];
	return provider;
}

+ (BOOL)initializeSystem
{
	return YES;
}

+ (UInt32)numAliveProviders
{
	return g_numAliveProviders;
}

- (id)initWithParameters:(NSDictionary *)params
				sizeType:(ESBannerViewSizeType)size
				delegate:(id<ESProviderBannerDelegate>)delegate_
{
	ES_LOG_INFO(@"Creating provider banner [0x%x] of class [%s]", self, class_getName([self class]));
	
	self = [super init];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.sizeType = size;
	self.delegate = delegate_;
	
	return self;
}

+(id)alloc
{
	++g_numAliveProviders;
	return [super alloc];
}

- (void)dealloc
{
	ES_LOG_INFO(@"Destroying provider banner [0x%x] of class [%s]", self, class_getName([self class]));
	
	self.delegate = nil;
	self.responseParameters = nil;
	
	[super dealloc];
	--g_numAliveProviders;
}

@end

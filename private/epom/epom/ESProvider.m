//
//  ESProvider.m
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProvider.h"

#import "EpomSettings.h"

#import "objc/runtime.h"

static UInt32 g_numAliveProviders = 0;

@implementation ESProvider

@synthesize delegate;
@synthesize responseParameters;
@synthesize sizeType;
@synthesize view;

+ (id)providerFromClass:(Class)cls parameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate;
{
	if ([cls instancesRespondToSelector:@selector(initWithParameters:sizeType:delegate:)] == NO)
	{
		ES_LOG_ERROR(@"Provider class [%@] does not respond to initialization selector", cls);
		
		return nil;
	}
	
	ESProvider *provider = [[[cls alloc] initWithParameters:params 
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

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	ES_LOG_INFO(@"Creating provider [0x%x] of class [%s]", self, class_getName([self class]));
	
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
	ES_LOG_INFO(@"Destroying provider [0x%x] of class [%s]", self, class_getName([self class]));
	
	self.delegate = nil;
	self.responseParameters = nil;
	
	[super dealloc];
	--g_numAliveProviders;
}

@end

//
//  ESProviderInterstitial.m
//  Epom SDK
//
//  Created by Epom LTD on 10/17/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitial.h"

#import "EpomSettings.h"

#import "objc/runtime.h"

@implementation ESProviderInterstitial

@synthesize delegate;
@synthesize responseParameters;

+ (id)providerInterstitialFromClass:(Class)cls parameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate;
{
	if ([cls instancesRespondToSelector:@selector(initWithParameters:delegate:)] == NO)
	{
		ES_LOG_ERROR(@"ProviderInterstitial class [%@] does not respond to initialization selector", cls);
		
		return nil;
	}
	
	ESProviderInterstitial *provider = [[[cls alloc] initWithParameters:params
															   delegate:delegate] autorelease];
	return provider;
}

+ (BOOL)initializeSystem
{
	return YES;
}

- (id)initWithParameters:(NSDictionary *)params
				delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	ES_LOG_INFO(@"Creating provider interstitial [0x%x] of class [%s]", self, class_getName([self class]));
	
	self = [super init];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.delegate = delegate_;
	
	return self;
}

- (void)dealloc
{
	ES_LOG_INFO(@"Destroying provider interstitial [0x%x] of class [%s]", self, class_getName([self class]));
	
	self.delegate = nil;
	self.responseParameters = nil;
	
	[super dealloc];
}

- (void)presentWithViewController:(UIViewController *)viewController
{
	NOENTRY;
}

@end

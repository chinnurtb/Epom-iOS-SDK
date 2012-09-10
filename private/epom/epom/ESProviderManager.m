//
//  ESProviderManager.m
//  Epom SDK
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderManager.h"

#import "EpomProvidersList.h"

#import "EpomSettings.h"

#import "ESProvider.h"

#import <UIKit/UIWebView.h>

@implementation ESProviderManager

@synthesize safariUserAgent;

static ESProviderManager* _shared = nil;

+(ESProviderManager*)shared
{
	@synchronized([ESProviderManager class])
	{
		if (!_shared)
			[[self alloc] init];
		
		return _shared;
	}
	
	return nil;
}

+(id)alloc
{
	@synchronized([ESProviderManager class])
	{
		NSAssert(_shared == nil, @"Attempted to allocate a second instance of a singleton.");
		_shared = [super alloc];
		return _shared;
	}
	
	return nil;
}

-(id)init 
{
	self = [super init];
	
	if (self == nil)
	{
		return nil;
	}
	
	availableProviders = [[NSMutableDictionary alloc] init];
	
	UInt32 numProviders = ARRAY_SIZE(FULL_PROVIDERS_LIST);
	
	ES_LOG_INFO(@"Start listing available adnetworks providers");
	
	for (UInt32 i = 0; i < numProviders; ++i)
	{
		NSString *networkID = FULL_PROVIDERS_LIST[i][0];
		NSString *providerClassName = FULL_PROVIDERS_LIST[i][1];
		
		Class class = NSClassFromString(providerClassName);
		
		if (class != nil)
		{
			if ([class initializeSystem])
			{
				[availableProviders setValue:class forKey:networkID];
				
				ES_LOG_INFO(@"  Provider [%@] for network id [%@] is available.", providerClassName, networkID);
			}							
		}		
	}
	
	ES_LOG_INFO(@"End listing available adnetworks providers");
	
	
	// define user agent
	{
		UIWebView *webView = [[UIWebView alloc] init];
		safariUserAgent = [[webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] retain];
		[webView release];		
	}

	return self;
}

-(void)dealloc
{
	[safariUserAgent release], safariUserAgent = nil;
	[availableProviders release], availableProviders = nil;
	[super dealloc];
}

-(Class)providerClassForID:(NSString *)providerID
{
	return [availableProviders valueForKey:providerID];
}

@end

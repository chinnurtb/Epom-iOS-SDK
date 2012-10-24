//
//  ESBannerInner.m
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESInterstitialInner.h"

#import "ESInterstitialView+.h"

// provider
#import "ESProviderInterstitial.h"

#import "ESLocationTracker.h"

// es number
#import "Utilities/ESNumber.h"

// providers manager
#import "ESProviderManager.h"

// externals
#import "CutTouchJSON/JSON/CutJSONDeserializer.h"

// version
#import "epom/ESVersion.h"

//
#import "ESStartupInterstitialWindow.h"

// objc
#import <objc/runtime.h>

#import <mach/mach.h>

#pragma mark -- ESInterstitialInner private interface

@interface ESInterstitialInner()

@property (readwrite, assign) ESInterstitialView *parent;

@property (readwrite, retain) NSString *apiKey;
@property (readwrite, retain) NSURLConnection *requestConnection;
@property (readwrite, retain) NSURLConnection *impressionConnection;
@property (readwrite, retain) NSURLConnection *clickConnection;

@property (readwrite, retain) NSMutableData *recievedData;

@property (readwrite, retain) NSMutableSet *bannedBannerIDs;
@property (readwrite, retain) NSMutableDictionary *tempBannedBannerIDs;

@property (readwrite, retain) ESProviderInterstitial *currentProvider;

@property (readwrite, assign) BOOL testMode;

@property (readwrite, retain) ESStartupInterstitialWindow *startupWindow;

@end

#pragma mark -- ESInterstitialInner implementation

@implementation ESInterstitialInner
@synthesize parent;
@synthesize apiKey;

@synthesize requestConnection;
@synthesize impressionConnection;
@synthesize clickConnection;

@synthesize recievedData;

@synthesize bannedBannerIDs;
@synthesize tempBannedBannerIDs;

@synthesize currentProvider;
@synthesize testMode;

@synthesize loadTimeout;

@synthesize startupWindow;

#pragma mark -- ESInterstitialInner public methods implementation

- (id)initWithParent:(ESInterstitialView *)parentView ID:(NSString*)ID
		 useLocation:(BOOL)doUseLocation testMode:(BOOL)inTestMode
{
	self = [super init];
	
	if (nil == self)
	{
		return nil;
	}
	
	self.parent = parentView;
	self.apiKey = ID;
	self.testMode = inTestMode;
	self.state = ESInterstitialViewStateInitializing;
	
	[[ESLocationTracker shared] setForceUseLocation:doUseLocation];
		
	self.recievedData = [[[NSMutableData alloc] init] autorelease];
	
	self.bannedBannerIDs = [[[NSMutableSet alloc] init] autorelease];
	self.tempBannedBannerIDs = [[[NSMutableDictionary alloc] init] autorelease];
		
	return self;
}


-(void)dealloc
{
	self.apiKey = nil;
	self.requestConnection = nil;
	self.impressionConnection = nil;
	self.clickConnection = nil;
	self.recievedData = nil;
	
	self.bannedBannerIDs = nil;
	self.tempBannedBannerIDs = nil;
	
	if (self.currentProvider != nil)
	{
		self.currentProvider.delegate = nil;
		self.currentProvider = nil;
	}
	
	if (self.startupWindow)
	{
		[self.startupWindow dismiss];
		self.startupWindow = nil;
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[super dealloc];
}

- (void)reload
{
	switch (self.state)
	{
		case ESInterstitialViewStateInitializing:
		case ESInterstitialViewStateFailed:
		case ESInterstitialViewStateDone:
			// remove current provider
			if (self.currentProvider != nil)
			{
				self.currentProvider.delegate = nil;
				self.currentProvider = nil;
			}

			// clear temporary banned banners
			[self.tempBannedBannerIDs removeAllObjects];
			
			[self requestAdAfter:AD_REQUEST_START_INTERVAL];
			if (self.loadTimeout != 0.0)
			{
				[self performSelector:@selector(cancelAdRequestByTimeout) withObject:nil afterDelay:self.loadTimeout];
			}
			break;
		default:
			// do nothing
			ES_LOG_ERROR(@"Can't reload interstitial ad view. It's displayed now or is loading.");
			break;
	}
}

- (void)presentWithViewController:(UIViewController *)viewController
{
	if ((self.state != ESInterstitialViewStateReady) && (self.state != ESInterstitialViewStateDone))
	{
		ES_LOG_ERROR(@"Can't present interstitial ad view. It's not loaded yet or already is displayed.");
		return;
	}
	
	ASSERT(self.currentProvider != nil);
	
	[self.currentProvider presentWithViewController:viewController];
}

- (void)presentAsStartupScreenWithWindow:(UIWindow *)window defaultImage:(UIImage *)image
{
	self.startupWindow = [[[ESStartupInterstitialWindow alloc] initAndPresentWithReplacedWindow:window image:image] autorelease];
}

#pragma mark -- ESInterstitialInner private methods implementation

- (NSURL *)generateAdRequestURL
{
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@?key=%@&udid=%@&version=%i.%i.%i"
								  				, [NSString stringWithFormat:AD_REQUEST_URL_FORMAT, [ESUtilsPrivate shared].adsServerUrl]
								  				, self.apiKey
								  				, [ESUtilsPrivate deviceUUID]
								  				, VERSION_MAJOR
								  				, VERSION_MINOR
								  				, VERSION_BUILD];
	
	// permanently banned ids
	for (NSString *bannerId in self.bannedBannerIDs)
	{
		[urlString appendFormat:@"&excluded=%@", bannerId];
	}	
	
	// temporarily banned ids
	for (NSString *bannerId in self.tempBannedBannerIDs)
	{		
		[urlString appendFormat:@"&excluded=%@", bannerId];
	}
	
	return [NSURL URLWithString:urlString];
}

- (NSURL *)generateAdFeedbackWithURL:(NSString *)url parameters:(NSDictionary *)parameters attachSignature:(BOOL)attachSignature
{
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", url];
	
	[urlString appendFormat:@"?b=%@", [parameters valueForKey:ADNETWORK_BANNER_ID_KEY]];
	[urlString appendFormat:@"&p=%@", [parameters valueForKey:ADNETWORK_PLACEMENT_ID_KEY]];
	[urlString appendFormat:@"&c=%@", [parameters valueForKey:ADNETWORK_CAMPAIGN_ID_KEY]];
	[urlString appendFormat:@"&l=%@", [parameters valueForKey:ADNETWORK_COUNTRY_KEY]];
	[urlString appendFormat:@"&h=%@", [parameters valueForKey:ADNETWORK_HASH_KEY]];
	[urlString appendFormat:@"&udid=%@", [ESUtilsPrivate deviceUUID]];
	
	if (attachSignature)
	{
		NSString *signature = [parameters valueForKey:ADNETWORK_SIGNATURE_KEY];
		if (signature != nil)
		{
			[urlString appendFormat:@"&s=%@", signature];	
		}
	}
	
	return [NSURL URLWithString:urlString];
}

- (void)requestAdAfter:(NSTimeInterval)seconds
{
	if (self.state != ESInterstitialViewStateLoading)
	{
		self.state = ESInterstitialViewStateLoading;
		if ([self.parent.delegate respondsToSelector:@selector(esInterstitialViewDidStartLoadAd:)])
		{
			[self.parent.delegate esInterstitialViewDidStartLoadAd:self.parent];
		}
	}
	
	[self performSelector:@selector(sendAdRequest) withObject:nil afterDelay:seconds];
}

- (void)cancelAdRequestByTimeout
{
	ES_LOG_ERROR(@"ESInterstitialView - interstitial ad load timeout is finished. Aborting ad request.");
	
	[self adRequestFailed];
}

- (void)sendAdRequest
{
	// clear current data
	[self.recievedData setLength: 0];
	
	NSURL *url = [self generateAdRequestURL];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:HTTP_AD_REQUEST_TIMEOUT];
	
	[request setValue:[ESProviderManager shared].safariUserAgent forHTTPHeaderField:@"User-Agent"];
	
	// make connection with request
	self.requestConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)adRequestFailed
{
	if (self.state == ESInterstitialViewStateLoading)
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		
		if (self.requestConnection != nil)
		{
			[self.requestConnection cancel];
			self.requestConnection = nil;
		}
		
		if (self.currentProvider != nil)
		{
			self.currentProvider.delegate = nil;
			self.currentProvider = nil;
		}

		self.state = ESInterstitialViewStateFailed;

		if (self.startupWindow != nil)
		{
			[self.startupWindow dismiss];
			self.startupWindow = nil;
		}
		
		if ([self.parent.delegate respondsToSelector:@selector(esInterstitialViewDidFailLoadAd:)])
		{
			[self.parent.delegate esInterstitialViewDidFailLoadAd:self.parent];
		}
	}
}

#pragma mark --NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	ES_LOG_ERROR(@"ESInterstitialView - Connection failed with error: %@", error);
	
	if (connection == self.requestConnection)
	{
		self.requestConnection = nil;
				
		[self requestAdAfter:AD_NETWORK_ERR_INTERVAL];
	}
	
	if (connection == self.impressionConnection)
	{
		self.impressionConnection = nil;
	}
	
	if (connection == self.clickConnection)
	{
		self.clickConnection = nil;
	}
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (connection == self.requestConnection)
	{
		self.requestConnection = nil;

		if (self.recievedData.length == 0)
		{
			// cant get any interstitial ad. canceling load
			ES_LOG_ERROR(@"ESInterstitialView - can't get any interstitial ad for displaying. Canceling load.");
			
			[self adRequestFailed];
		}
		else
		{
			// process recieved data
			NSError *jsonError = 0;
			NSDictionary *requestResult = [[CutJSONDeserializer deserializer] deserializeAsDictionary: self.recievedData error: &jsonError];
			
			
			if ([self processResponse:requestResult] == FALSE)
			{
				[self requestAdAfter: AD_REQUEST_START_INTERVAL];
			}
		}

	}
	
	if (connection == self.impressionConnection)
	{
		self.impressionConnection = nil;
	}
	
	if (connection == self.clickConnection)
	{
		self.clickConnection = nil;
	}
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection == self.requestConnection)
	{
		[self.recievedData appendData: data];		
	}
}

#pragma mark -- response processing

- (BOOL)processResponse:(NSDictionary *)response
{
	if (response == nil)
	{
		return NO;
	}
	
	NSString *type = [response valueForKey:ADNETWORK_TYPE_KEY];
	NSString *bannerId = [[response valueForKey:ADNETWORK_BANNER_ID_KEY] stringValue];
	BOOL contentADNetwork = NO;
	
	if (type == nil)
	{
		if ([response valueForKey:ADNETWORK_CONTENT_KEY] != nil)
		{
			contentADNetwork = true;
			type = ADNETWORK_CONTENT_TYPE;
		}
		else
		{
			ES_LOG_ERROR(@"ESInterstitialView - Can't read adnetwork type from ad-request's response [%@]", response);
			
			return NO;
		}		
	}
	
	Class class = [[ESProviderManager shared] providerInterstitialClassForID:type];
	
	if (class == nil)
	{
		ES_LOG_ERROR(@"ESInterstitialView - Provider interstitial class for network type [%@] absent.", type);
		
		[self.bannedBannerIDs addObject: bannerId];
		return NO;
	}
	
	NSDictionary *providerParameters = contentADNetwork ? response : [response valueForKey:ADNETWORK_PARAMETERS_KEY];
	
	ASSERT(self.currentProvider == nil);
	
	self.currentProvider = [ESProviderInterstitial providerInterstitialFromClass:class
																	  parameters:providerParameters
																		delegate:self];
	
	if (self.currentProvider == nil)
	{
		ES_LOG_ERROR(@"ESInterstitialView - Provider interstitial for network type [%@] cannot be initiated.", type);
		
		[self.bannedBannerIDs addObject: bannerId];
		return NO;
	}
	
	self.currentProvider.responseParameters = response;
	
	return YES;
}

#pragma mark -- ESProviderInterstitialDelegate implementation

- (void)providerDidRecieveAd:(ESProviderInterstitial *)provider
{
	ES_LOG_INFO(@"ESInterstitialView - Provider interstitial [0x%x] (is pending: %s) of class [%s] has recieved ad",
				provider, (provider == self.currentProvider) ? "true" : "false", class_getName([provider class]));

	if (provider == self.currentProvider)
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		
		self.state = ESInterstitialViewStateReady;

		if (self.startupWindow)
		{
			[self presentWithViewController:self.startupWindow.rootViewController];
		}
				
		if ([self.parent.delegate respondsToSelector:@selector(esInterstitialViewDidLoadAd:)])
		{
			[self.parent.delegate esInterstitialViewDidLoadAd:self.parent];
		}
	}

}

- (void)providerFailedToRecieveAd:(ESProviderInterstitial *)provider
{
	ES_LOG_INFO(@"ESInterstitialView - Provider interstitial [0x%x] (is pending: %s) of class [%s] has failed to recieve ad.",
				provider, (provider == self.currentProvider) ? "true" : "false", class_getName([provider class]));
	
	if (provider == self.currentProvider)
	{
		self.currentProvider.delegate = nil;
		self.currentProvider = nil;
		
		[self requestAdAfter:AD_NETWORK_ERR_INTERVAL];
		
		// add temp banned
		[self.tempBannedBannerIDs setValue:[NSNumber numberWithDouble:AD_TEMP_BANNER_BAN_TIME]
									forKey:[[provider.responseParameters valueForKey:ADNETWORK_BANNER_ID_KEY] stringValue]];		
	}
}

-(void)providerViewWillEnterModalMode:(ESProviderInterstitial *)provider
{
	ES_LOG_INFO(@"ESInterstitialView - Provider interstitial [0x%x] of class [%s] will enter modal mode.", provider, class_getName([provider class]));
	
	// retain to make sure that self will not be deleted until modal view close
	[self retain];
	
	ASSERT(self.state == ESInterstitialViewStateReady || self.state == ESInterstitialViewStateDone);
	
	self.state = ESInterstitialViewStateActive;
	
	if ([self.parent.delegate respondsToSelector:@selector(esInterstitialViewWillEnterModalMode:)])
	{
		[self.parent.delegate esInterstitialViewWillEnterModalMode:self.parent];
	}
	
	// post impression
	{
		NSURL *impressionURL = [self generateAdFeedbackWithURL:[NSString stringWithFormat:AD_IMPRESSION_URL_FORMAT, [ESUtilsPrivate shared].adsServerUrl]
													parameters:provider.responseParameters
											   attachSignature:YES];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:impressionURL
												 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
											 timeoutInterval:HTTP_AD_IMPRESSION_TIMEOUT];
		
		// make connection with request
		self.impressionConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	}	
}

-(void)providerViewDidLeaveModalMode:(ESProviderInterstitial *)provider
{
	ES_LOG_INFO(@"ESInterstitialView - Provider interstitial [0x%x] of class [%s] did leave modal mode.", provider, class_getName([provider class]));
	
	ASSERT(self.state == ESInterstitialViewStateActive);
	
	self.state = ESInterstitialViewStateDone;
	
	if (self.startupWindow)
	{
		[self.startupWindow dismiss];
		self.startupWindow = nil;
	}

	if ([self.parent.delegate respondsToSelector:@selector(esInterstitialViewDidLeaveModalMode:)])
	{
		[self.parent.delegate esInterstitialViewDidLeaveModalMode:self.parent];
	}
	
	// release retained while switching to modal view
	[self release];
}

-(void)providerViewUserInteraction:(ESProviderInterstitial *)provider willLeaveApplication:(BOOL)yesOrNo
{
	ES_LOG_INFO(@"ESInterstitialView - Provider interstitial [0x%x] of class [%s] - user interaction performed. Will leave application - %s.", provider, class_getName([provider class]), yesOrNo ? "yes" : "no");

	// post click
	{
		NSURL *clickURL = [self generateAdFeedbackWithURL:[NSString stringWithFormat:AD_CLICK_URL_FORMAT, [ESUtilsPrivate shared].adsServerUrl]
											   parameters:provider.responseParameters
										  attachSignature:NO];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:clickURL
												 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
											 timeoutInterval:HTTP_AD_CLICK_TIMEOUT];
		
		// make connection with request
		self.clickConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	}

	if ([self.parent.delegate respondsToSelector:@selector(esInterstitialViewUserInteraction:willLeaveApplication:)])
	{
		[self.parent.delegate esInterstitialViewUserInteraction:self.parent willLeaveApplication:yesOrNo];
	}	
}

-(BOOL)inTestMode
{
	return self.testMode;
}

@end

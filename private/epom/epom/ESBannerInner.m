//
//  ESBannerInner.m
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESBannerInner.h"

#import "ESBannerView+.h"

// provider
#import "ESProviderBanner.h"

// es location tracker
#import "ESLocationTracker.h"

// es number
#import "Utilities/ESNumber.h"

// providers manager
#import "ESProviderManager.h"

// timer wrapper
#import "ESBannerInnerTimerWrapper.h"

// settings
#import "EpomSettings.h"

// externals
#import "CutTouchJSON/JSON/CutJSONDeserializer.h"

// version
#import "epom/ESVersion.h"

// objc
#import <objc/runtime.h>

#import <mach/mach.h>

static UInt32 g_numAliveViews = 0;

@interface ESBannerInner()

@property (readwrite, assign) ESBannerView *parent;

@property (readwrite, retain) NSString *apiKey;
@property (readwrite, retain) NSURLConnection *requestConnection;
@property (readwrite, retain) NSURLConnection *impressionConnection;
@property (readwrite, retain) NSURLConnection *clickConnection;

@property (readwrite, retain) NSMutableData *recievedData;

@property (readwrite, retain) NSMutableSet *bannedBannerIDs;
@property (readwrite, retain) NSMutableDictionary *tempBannedBannerIDs;

@property (readwrite, retain) ESProviderBanner *currentProvider;
@property (readwrite, retain) ESProviderBanner *desiredProvider;
@property (readwrite, retain) ESBannerInnerTimerWrapper *timerWrapper;

@property (readwrite, assign) ESBannerViewSizeType sizeType;
@property (readwrite, retain) UIViewController *modalViewController;

@property (readwrite, assign) BOOL testMode;

@property (readwrite, assign) BOOL updateEnabled;
@property (readwrite, assign) double adRequestCountDown;

@end

#pragma mark --utility section

static inline NSTimeInterval randomTimeInterval(NSTimeInterval min, NSTimeInterval max)
{
	return min + (max - min) * random() / RAND_MAX;
}

@implementation ESBannerInner
@synthesize parent;
@synthesize apiKey;
@synthesize requestConnection;
@synthesize impressionConnection;
@synthesize clickConnection;
@synthesize recievedData;
@synthesize bannedBannerIDs;
@synthesize tempBannedBannerIDs;
@synthesize currentProvider;
@synthesize desiredProvider;
@synthesize timerWrapper;
@synthesize modalViewController;
@synthesize sizeType;
@synthesize refreshTimeInterval;
@synthesize testMode;
@synthesize updateEnabled;
@synthesize adRequestCountDown;

#pragma mark -- Initialization section

- (id)initWithParent:(ESBannerView *)parentView ID:(NSString*)ID sizeType:(ESBannerViewSizeType)size modalViewController:(UIViewController *)controller
		 useLocation:(BOOL)doUseLocation testMode:(BOOL)inTestMode
{
	self = [super init];
	
	if (nil == self)
	{
		return nil;
	}
	
	self.parent = parentView;
	self.apiKey = ID;
	self.sizeType = size;
	self.testMode = inTestMode;
	self.modalViewController = controller;
	

	[[ESLocationTracker shared] setForceUseLocation:doUseLocation];
			
	self.recievedData = [[[NSMutableData alloc] init] autorelease];
	
	self.bannedBannerIDs = [[[NSMutableSet alloc] init] autorelease];
	self.tempBannedBannerIDs = [[[NSMutableDictionary alloc] init] autorelease];
	
	self.timerWrapper = [[[ESBannerInnerTimerWrapper alloc] initWithESBannerInner:self] autorelease];
	
	// start polling requests
	self.updateEnabled = YES;
	[self requestAdAfter: AD_REQUEST_START_INTERVAL];
	
	return self;
}

+(id)alloc
{
	++g_numAliveViews;
	
	return [super alloc];
}

-(void)dealloc
{
	[self.timerWrapper stop];
	
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
	
	if (self.desiredProvider != nil)
	{
		self.desiredProvider.delegate = nil;
		self.desiredProvider = nil;
	}

	self.timerWrapper = nil;
	
	[super dealloc];
	
	--g_numAliveViews;
}

+ (UInt32) numAliveViews
{
	return g_numAliveViews;
}

#pragma mark -- Request urls

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

#pragma mark -- ads request polling

- (void)requestAdAfter: (NSTimeInterval)delay
{
	self.adRequestCountDown = delay;	
}

#pragma mark -- update

- (void)onUpdate
{
	/*
#ifdef DEBUG
	ES_LOG_INFO(@"Application memory usage: %i KBytes. Alive providers %i. Alive views %i", [self usedMemoryKBytes], [ESProviderBanner numAliveProviders], [ESBannerInner numAliveViews]);
#endif // DEBUG
	 */
	
	if (self.updateEnabled == YES)
	{
		// update requests		
		if (self.adRequestCountDown >= 0.f)
		{
			self.adRequestCountDown -= AD_UPDATE_INTERVAL;
			
			if (self.adRequestCountDown < 0.f)
			{
				if (self.desiredProvider != nil)
				{
					// remove desired provider - possibly it is stuck
					self.desiredProvider.delegate = nil;
					self.desiredProvider = nil;
				}
				
				// clear current data
				[self.recievedData setLength: 0];
				
				// generate request string
				
				NSURL *url = [self generateAdRequestURL];
				NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:HTTP_AD_REQUEST_TIMEOUT];
				
				[request setValue:[ESProviderManager shared].safariUserAgent forHTTPHeaderField:@"User-Agent"];
				
				// make connection with request		
				self.requestConnection = [NSURLConnection connectionWithRequest:request delegate:self];
			}
		}
		
		// update banned
		
		if ([self.tempBannedBannerIDs count] > 0)
		{
			NSMutableArray *tmpArray = [[[NSMutableArray alloc] init] autorelease];
			
			for (NSString *key in self.tempBannedBannerIDs)
			{
				ESNumber *countdown = [self.tempBannedBannerIDs valueForKey:key];
				countdown.value = countdown.value - AD_UPDATE_INTERVAL;
				
				if (countdown.value < 0)
				{
					[tmpArray addObject:key];
				}
			}
			
			for (NSString *value in tmpArray) 
			{
				[self.tempBannedBannerIDs removeObjectForKey:value];
			}
		}		
	}
}

#pragma mark --NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	ES_LOG_ERROR(@"ESBannerView - Connection failed with error: %@", error);
	
	if (connection == self.requestConnection)
	{
		self.requestConnection = nil;
				
		// handle error here	
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
		
		// process recieved data		
		NSTimeInterval nextRequestDelay = 0.0;
		
		NSError *jsonError = 0;
		NSDictionary *requestResult = [[CutJSONDeserializer deserializer] deserializeAsDictionary: self.recievedData error: &jsonError];
		UInt32 dataLength = self.recievedData.length;
		if (([self processResponse:requestResult] == YES) || (dataLength == 0))
		{
			nextRequestDelay = self.refreshTimeInterval;
		}
		else
		{
			nextRequestDelay = AD_NETWORK_ERR_INTERVAL;
		}
		
		// forward request
		[self requestAdAfter: nextRequestDelay];		
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
			ES_LOG_ERROR(@"ESBannerView - Can't read adnetwork type from ad-request's response [%@]", response);
			
			return NO;
		}		
	}
	
	Class class = [[ESProviderManager shared] providerBannerClassForID:type];
	
	if (class == nil)
	{
		ES_LOG_ERROR(@"ESBannerView - ProviderBanner class for network type [%@] absent.", type);
		
		[self.bannedBannerIDs addObject: bannerId];
		return NO;
	}
	
	NSDictionary *providerParameters = contentADNetwork ? response : [response valueForKey:ADNETWORK_PARAMETERS_KEY];
	
	ASSERT(self.desiredProvider == nil);

	self.desiredProvider = [ESProviderBanner providerBannerFromClass:class
														  parameters:providerParameters
															sizeType:self.sizeType
															delegate:self];
	
	if (self.desiredProvider == nil)
	{
		ES_LOG_ERROR(@"ESBannerView - ProviderBanner for network type [%@] cannot be initiated.", type);
		
		[self.bannedBannerIDs addObject: bannerId];
		return NO;
	}
	
	self.desiredProvider.responseParameters = response;
	
	return YES;
}

#pragma mark -- ESProviderBannerDelegate implementation

- (void)providerDidRecieveAd:(ESProviderBanner *)provider
{
	ES_LOG_INFO(@"ESBannerView - ProviderBanner [0x%x] (is pending: %s) of class [%s] has recieved ad.%s",
				provider, (provider == self.desiredProvider) ? "true" : "false", class_getName([provider class]),
				(updateEnabled ? "" : " Ignored due to ads update is disabled at the moment"));

	if (provider == self.desiredProvider)
	{
		if (updateEnabled == YES)
		{
			
			UIView *oldView = (self.currentProvider != nil) ? self.currentProvider.view : nil;
			UIView *newView = (self.desiredProvider != nil) ? self.desiredProvider.view : nil;
			
			[self transitViewFrom:oldView to:newView];
			
			self.currentProvider = provider;
			self.desiredProvider = nil;
		}
		else
		{
			// ignore ad. Modal view is displayed currently
			self.desiredProvider.delegate = nil;
			self.desiredProvider = nil;			
		}
	}
	/*
	else
	{
		ASSERT(provider == self.currentProvider);
	}
	*/

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


- (void)providerFailedToRecieveAd:(ESProviderBanner *)provider
{
	ES_LOG_INFO(@"ESBannerView - ProviderBanner [0x%x] (is pending: %s) of class [%s] has failed to recieve ad.",
				provider, (provider == self.desiredProvider) ? "true" : "false", class_getName([provider class]));
	
	if (provider == self.desiredProvider)
	{
		self.desiredProvider.delegate = nil;
		self.desiredProvider = nil;
		
		[self requestAdAfter:AD_NETWORK_ERR_INTERVAL];
		
		// add temp banned
		[self.tempBannedBannerIDs setValue:[ESNumber numberWithDouble:AD_TEMP_BANNER_BAN_TIME]
									forKey:[[provider.responseParameters valueForKey:ADNETWORK_BANNER_ID_KEY] stringValue]];
		
	}
	/*
	else
	{
		ASSERT(provider == self.currentProvider);
	}
	*/
}

-(void)providerViewWillEnterModalMode:(ESProviderBanner *)provider
{
	ES_LOG_INFO(@"ESBannerView - ProviderBanner [0x%x] of class [%s] will enter modal mode.", provider, class_getName([provider class]));
	
	self.updateEnabled = NO;
	
	// retain to make sure that self will not be deleted until modal view close
	[self retain];
	
	if ([self.parent.delegate respondsToSelector:@selector(esBannerViewWillEnterModalMode:)])
	{
		[self.parent.delegate esBannerViewWillEnterModalMode:self.parent];
	}
}

-(void)providerViewDidLeaveModalMode:(ESProviderBanner *)provider
{
	ES_LOG_INFO(@"ESBannerView - ProviderBanner [0x%x] of class [%s] did leave modal mode.", provider, class_getName([provider class]));
	
	self.updateEnabled = YES;

	if ([self.parent.delegate respondsToSelector:@selector(esBannerViewDidLeaveModalMode:)])
	{
		[self.parent.delegate esBannerViewDidLeaveModalMode:self.parent];
	}
	
	// release retained while switching to modal view
	[self release];	
}

-(void)providerViewWillLeaveApplication:(ESProviderBanner *)provider
{
	ES_LOG_INFO(@"ESBannerView - ProviderBanner [0x%x] of class [%s] will leave application.", provider, class_getName([provider class]));
	
	if ([self.parent.delegate respondsToSelector:@selector(esBannerViewWillLeaveApplication:)])
	{
		[self.parent.delegate esBannerViewWillLeaveApplication:self.parent];
	}	
}

-(void)providerViewHasBeenClicked:(ESProviderBanner *)provider
{	
	ES_LOG_INFO(@"ESBannerView - ProviderBanner [0x%x] of class [%s] ad has been tapped.", provider, class_getName([provider class]));
	
	// post click
	NSURL *clickURL = [self generateAdFeedbackWithURL:[NSString stringWithFormat:AD_CLICK_URL_FORMAT, [ESUtilsPrivate shared].adsServerUrl]
										   parameters:provider.responseParameters
									  attachSignature:NO];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:clickURL 
											 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
										 timeoutInterval:HTTP_AD_CLICK_TIMEOUT];
	
	// make connection with request
	self.clickConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	if ([self.parent.delegate respondsToSelector:@selector(esBannerViewAdHasBeenTapped:)])
	{
		[self.parent.delegate esBannerViewAdHasBeenTapped:self.parent];
	}
}

-(BOOL)inTestMode
{
	return self.testMode;
}

-(UIViewController*)screenPresentController
{
	return self.modalViewController;
}

#pragma mark -- views transition stuff

- (void)transitViewFrom:(UIView *)oldView to:(UIView *)newView
{
	if ([self.parent.delegate respondsToSelector:@selector(esBannerViewWillShowAd:)])
	{
		[self.parent.delegate esBannerViewWillShowAd:self.parent];
	}

	
	if (newView == oldView)
	{
		// if have the same view, just animate (specially for tapjoy)
		[UIView beginAnimations:@"ViewTransition" context:nil];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector: @selector(viewsTransitionWithAnimationID:finished:context:)];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
							   forView:self.parent
								 cache:NO];
		[UIView commitAnimations];
		
		return;
	}
	
	// common case
	if (newView != nil)
	{
		newView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
		UIViewAutoresizingFlexibleRightMargin;
		CGRect selfFrame = self.parent.frame;
		CGRect childFrame = newView.frame;
		newView.frame = CGRectMake((selfFrame.size.width - childFrame.size.width) / 2, 
								   0,
								   childFrame.size.width, childFrame.size.height);
	}
	
	[UIView beginAnimations:@"ViewTransition" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector: @selector(viewsTransitionWithAnimationID:finished:context:)];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
						   forView:self.parent
							 cache:NO];
	
	[oldView removeFromSuperview];
	[self.parent addSubview:newView];
	
	[UIView commitAnimations];
}

- (void)viewsTransitionWithAnimationID:(NSString *)animationID
							  finished:(BOOL)finished
							   context:(void *)context
{
	if ([self.parent.delegate respondsToSelector:@selector(esBannerViewDidShowAd:)])
	{
		[self.parent.delegate esBannerViewDidShowAd:self.parent];
	}
}

#pragma mark -- Used memory size
-(size_t)usedMemoryKBytes
{
	struct task_basic_info info;
	memset(&info, 0, sizeof(info));
	mach_msg_type_number_t size = sizeof(info);
	
	task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
	return info.resident_size / 1024;
}

@end

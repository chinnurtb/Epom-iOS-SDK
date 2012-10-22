//
//  ESViewInner.m
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESViewInner.h"

#import "ESView+.h"

// provider
#import "ESProvider.h"

// es number
#import "ESNumber.h"

// providers manager
#import "ESProviderManager.h"

// timer wrapper
#import "ESViewInnerTimerWrapper.h"

// settings
#import "EpomSettings.h"

// externals
#import "CutTouchJSON/JSON/CutJSONDeserializer.h"

// version
#import "epom/ESVersion.h"

// objc
#import <objc/runtime.h>

// network/mac address
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <mach/mach.h>

#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>

static UInt32 g_numAliveViews = 0;

@interface ESViewInner()

@property (readwrite, retain) NSString *apiKey;
@property (readwrite, retain) NSURLConnection *requestConnection;
@property (readwrite, retain) NSURLConnection *impressionConnection;
@property (readwrite, retain) NSURLConnection *clickConnection;

@property (readwrite, retain) NSMutableData *recievedData;

@property (readwrite, retain) NSMutableSet *bannedBannerIDs;
@property (readwrite, retain) NSMutableDictionary *tempBannedBannerIDs;

@property (readwrite, retain) ESProvider *currentProvider;
@property (readwrite, retain) ESProvider *desiredProvider;
@property (readwrite, retain) ESViewInnerTimerWrapper *timerWrapper;

@property (readwrite, assign) ESViewSizeType sizeType;
@property (readwrite, retain) UIViewController *modalViewController;

@property (readwrite, retain) CLLocationManager *locator;
@property (readwrite, retain) CLLocation *latestLocation;

@property (readwrite, assign) BOOL useLocation;
@property (readwrite, assign) BOOL testMode;

@property (readwrite, assign) BOOL updateEnabled;
@property (readwrite, assign) double adRequestCountDown;

@end

#pragma mark --utility section

static inline NSTimeInterval randomTimeInterval(NSTimeInterval min, NSTimeInterval max)
{
	return min + (max - min) * random() / RAND_MAX;
}

@implementation ESViewInner
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
@synthesize locator;
@synthesize latestLocation;
@synthesize sizeType;
@synthesize useLocation;
@synthesize testMode;
@synthesize updateEnabled;
@synthesize adRequestCountDown;

#pragma mark -- Initialization section

- (id)initWithID:(NSString*)ID sizeType:(ESViewSizeType)size modalViewController:(UIViewController *)controller useLocation:(BOOL)doUseLocation testMode:(BOOL)inTestMode
{
	self = [super initWithSizeType:size];
	
	if (nil == self)
		return nil;
	
	self.apiKey = ID;
	self.sizeType = size;
	self.useLocation = doUseLocation;
	self.testMode = inTestMode;
	self.modalViewController = controller;
	
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.backgroundColor = [UIColor clearColor];
	
	// try create
	if ([self locationManagerIsAvailable] && [self locationServicesAreAllowed])
	{
		self.locator = [[[CLLocationManager alloc] init] autorelease];
		self.locator.delegate = self;
		self.locator.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
		self.latestLocation = self.locator.location;
		
		if ((self.latestLocation == nil) && self.useLocation)
		{
			[self.locator startUpdatingLocation];
		}
		else
		{
			[self.locator startMonitoringSignificantLocationChanges];
		}
		
		
	}
	
	self.recievedData = [[[NSMutableData alloc] init] autorelease];
	
	self.bannedBannerIDs = [[[NSMutableSet alloc] init] autorelease];
	self.tempBannedBannerIDs = [[[NSMutableDictionary alloc] init] autorelease];
	
	self.timerWrapper = [[[ESViewInnerTimerWrapper alloc] initWithESViewInner:self] autorelease];	
	
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
	if (self.locator != nil)
	{
		self.locator.delegate = nil;
		self.locator = nil;
	}
	
	self.latestLocation = nil;
	self.timerWrapper = nil;
	
	[super dealloc];
	
	--g_numAliveViews;
}

+ (UInt32) numAliveViews
{
	return g_numAliveViews;
}

#pragma mark -- Features availability checks

- (BOOL)locationManagerIsAvailable
{	
	if (NSClassFromString(@"CLLocationManager") == nil)
	{
		return NO;
	}
	
	BOOL enabledAvailable = [CLLocationManager instancesRespondToSelector:@selector(locationServicesEnabled)];
	BOOL monitoringAvailable = [CLLocationManager instancesRespondToSelector:@selector(startMonitoringSignificantLocationChanges)];
	
	return  enabledAvailable && monitoringAvailable && [CLLocationManager locationServicesEnabled];
}

- (BOOL)locationServicesAreAllowed
{
	CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
	return (status == kCLAuthorizationStatusAuthorized) || (self.useLocation && (status == kCLAuthorizationStatusNotDetermined));
}

#pragma mark -- Request urls

- (NSURL *)generateAdRequestURL
{
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@?key=%@&udid=%@&version=%i.%i.%i"
								  				, AD_REQUEST_URL
								  				, self.apiKey
								  				, [self deviceMACAdressSHA1]
								  				, VERSION_MAJOR
								  				, VERSION_MINOR
								  				, VERSION_BUILD];
	
	// permanently banned ids
	for (NSNumber *bannerId in self.bannedBannerIDs)
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
	ES_LOG_INFO(@"Application memory usage: %i KBytes. Alive providers %i. Alive views %i", [self usedMemoryKBytes], [ESProvider numAliveProviders], [ESViewInner numAliveViews]);
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
	ES_LOG_ERROR(@"Connection failed with error: %@", error);
	
	if (connection == self.requestConnection)
	{
		self.requestConnection = nil;
				
		// handle error here	
		[self requestAdAfter:AD_REQUEST_ERR_INTERVAL];		
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

#pragma mark -- CLLocationManagerDelegate implementation

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	self.latestLocation = newLocation;
	if (oldLocation == nil)
	{
		// enable default mode
		[self.locator stopUpdatingLocation];
		[self.locator startMonitoringSignificantLocationChanges];
	}
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	ES_LOG_ERROR(@" Location manager error: %@", error);
}


#pragma mark -- response processing

- (BOOL)processResponse:(NSDictionary *)response
{
	if (response == nil)
	{
		return NO;
	}
	
	NSString *type = [response valueForKey:ADNETWORK_TYPE_KEY];
	NSNumber *bannerId = [response valueForKey:ADNETWORK_BANNER_ID_KEY];
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
			ES_LOG_ERROR(@"Can't read adnetwork type from ad-request's response [%@]", response);
			
			return NO;
		}		
	}
	
	Class class = [[ESProviderManager shared] providerClassForID:type];
	
	if (class == nil)
	{
		ES_LOG_ERROR(@"Provider class for network type [%@] absent.", type);
		
		[self.bannedBannerIDs addObject: bannerId];
		return NO;
	}
	
	NSDictionary *providerParameters = contentADNetwork ? response : [response valueForKey:ADNETWORK_PARAMETERS_KEY];
	
	assert(self.desiredProvider == nil);
	
	self.desiredProvider = [ESProvider providerFromClass:class 
											  parameters:providerParameters 
												sizeType:self.sizeType 
												delegate:self];
	
	if (self.desiredProvider == nil)
	{
		ES_LOG_ERROR(@"Provider for network type [%@] cannot be initiated.", type);
		
		[self.bannedBannerIDs addObject: bannerId];
		return NO;
	}
	
	self.desiredProvider.responseParameters = response;
	
	return YES;
}

#pragma mark -- ESProviderDelegate implementation

- (void)providerDidRecieveAd:(ESProvider *)provider
{
	ES_LOG_INFO(@"Provider [0x%x] (is pending: %s) of class [%s] has recieved ad.%s",
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
		assert(provider == self.currentProvider);
	}
	*/

	// post impression
	{
		NSURL *impressionURL = [self generateAdFeedbackWithURL:AD_IMPRESSION_URL parameters:provider.responseParameters attachSignature:YES];
		
		NSURLRequest *request = [NSURLRequest requestWithURL:impressionURL 
												 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
											 timeoutInterval:HTTP_AD_IMPRESSION_TIMEOUT];
		
		// make connection with request
		self.impressionConnection = [NSURLConnection connectionWithRequest:request delegate:self];			
	}
}


- (void)providerFailedToRecieveAd:(ESProvider *)provider
{
	ES_LOG_INFO(@"Provider [0x%x] (is pending: %s) of class [%s] has failed to recieve ad.",
				provider, (provider == self.desiredProvider) ? "true" : "false", class_getName([provider class]));
	
	if (provider == self.desiredProvider)
	{
		self.desiredProvider.delegate = nil;
		self.desiredProvider = nil;
		
		[self requestAdAfter:AD_NETWORK_ERR_INTERVAL];
		
		// add temp banned
		[self.tempBannedBannerIDs setValue:[ESNumber numberWithDouble:AD_TEMP_BANNER_BAN_TIME]
									forKey: [[provider.responseParameters valueForKey:ADNETWORK_BANNER_ID_KEY] stringValue] ];
		
	}
	/*
	else
	{
		assert(provider == self.currentProvider);
	}
	*/
}

-(void)providerViewWillEnterModalMode:(ESProvider *)provider
{
	ES_LOG_INFO(@"Provider [0x%x] of class [%s] will enter modal mode.", provider, class_getName([provider class]));
	
	self.updateEnabled = NO;
	
	// retain to make sure that self will not be deleted until modal view close
	[self retain];
	
	if ([self.delegate respondsToSelector:@selector(esViewWillEnterModalMode:)])
	{
		[self.delegate esViewWillEnterModalMode:self];
	}
}

-(void)providerViewDidLeaveModalMode:(ESProvider *)provider
{
	ES_LOG_INFO(@"Provider [0x%x] of class [%s] did leave modal mode.", provider, class_getName([provider class]));
	
	self.updateEnabled = YES;

	// release retained while switching to modal view
	[self release];

	if ([self.delegate respondsToSelector:@selector(esViewDidLeaveModalMode:)])
	{
		[self.delegate esViewDidLeaveModalMode:self];
	}
}

-(void)providerViewWillLeaveApplication:(ESProvider *)provider
{
	ES_LOG_INFO(@"Provider [0x%x] of class [%s] will leave application.", provider, class_getName([provider class]));
	
	if ([self.delegate respondsToSelector:@selector(esViewWillLeaveApplication:)])
	{
		[self.delegate esViewWillLeaveApplication:self];
	}	
}

-(void)providerViewHasBeenClicked:(ESProvider *)provider
{	
	ES_LOG_INFO(@"Provider [0x%x] of class [%s] ad has been tapped.", provider, class_getName([provider class]));
	
	// post click
	NSURL *clickURL = [self generateAdFeedbackWithURL:AD_CLICK_URL parameters:provider.responseParameters attachSignature:NO];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:clickURL 
											 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
										 timeoutInterval:HTTP_AD_CLICK_TIMEOUT];
	
	// make connection with request
	self.clickConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	if ([self.delegate respondsToSelector:@selector(esViewAdHasBeenTapped:)])
	{
		[self.delegate esViewAdHasBeenTapped:self];
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

-(CLLocation *)currentLocation
{
	if ((self.locator == nil) && [self locationManagerIsAvailable] && [self locationServicesAreAllowed])
	{
		self.locator = [[[CLLocationManager alloc] init] autorelease];
		self.locator.delegate = self;
		self.latestLocation = self.locator.location;
		
		if ((self.latestLocation == nil) && self.useLocation)
		{
			[self.locator startUpdatingLocation];
		}
		else
		{
			[self.locator startMonitoringSignificantLocationChanges];
		}
	}
		
	return self.latestLocation;
}

#pragma mark -- views transition stuff

- (void)transitViewFrom:(UIView *)oldView to:(UIView *)newView
{
	if ([self.delegate respondsToSelector:@selector(esViewWillShowAd:)])
	{
		[self.delegate esViewWillShowAd:self];
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
							   forView:self
								 cache:NO];
		[UIView commitAnimations];
		
		return;
	}
	
	// common case
	if (newView != nil)
	{
		newView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
		UIViewAutoresizingFlexibleRightMargin;
		CGRect selfFrame = self.frame;
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
						   forView:self
							 cache:NO];
	
	[oldView removeFromSuperview];
	[self addSubview:newView];
	
	[UIView commitAnimations];
}

- (void)viewsTransitionWithAnimationID:(NSString *)animationID
							  finished:(BOOL)finished
							   context:(void *)context
{
	if ([self.delegate respondsToSelector:@selector(esViewDidShowAd:)])
	{
		[self.delegate esViewDidShowAd:self];
	}
}

#pragma mark -- get mac address

- (NSString *)deviceMACAdressSHA1
{
	int                 mgmtInfoBase[6];
	char                *msgBuffer = NULL;
	size_t              length;
	unsigned char       macAddress[6];
	struct if_msghdr    *interfaceMsgStruct;
	struct sockaddr_dl  *socketStruct;
	BOOL 				error = NO;
	NSString			*result = nil;
	
	// Setup the management Information Base (mib)
	mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
	mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
	mgmtInfoBase[2] = 0;              
	mgmtInfoBase[3] = AF_LINK;        // Request link layer information
	mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
	
	// With all configured interfaces requested, get handle index
	if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) 
	{
		error = YES;
	}
	else
	{
		// Get the size of the data available (store in len)
		if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) 
		{
			error = YES;
		}
		else
		{
			// Alloc memory based on above call
			if ((msgBuffer = malloc(length)) == NULL)
			{
				error = YES;
			}
			else
			{
				// Get system information, store in buffer
				if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
				{
					error = YES;
				}
			}
		}
	}
	
	
	// Befor going any further...
	if (error == NO)
	{
		// Map msgbuffer to interface message structure
		interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
		
		// Map to link-level socket structure
		socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
		
		// Copy link layer address data in socket structure to an array
		memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
		
		// Read from char array into a string object, into traditional Mac address format
		result = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
									macAddress[0], macAddress[1], macAddress[2], 
									macAddress[3], macAddress[4], macAddress[5]];
	}
	
	
	// Release the buffer memory
	free(msgBuffer);
	
	// compute SHA1
	if (result)
	{
		const char *cstr = [result cStringUsingEncoding:NSUTF8StringEncoding];
		NSData *data = [NSData dataWithBytes:cstr length:result.length];
		
		uint8_t digest[CC_SHA1_DIGEST_LENGTH];
		
		CC_SHA1(data.bytes, data.length, digest);
		
		NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
		
		for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
			[output appendFormat:@"%02x", digest[i]];
		
		result = output;
	}
	
	return result;
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

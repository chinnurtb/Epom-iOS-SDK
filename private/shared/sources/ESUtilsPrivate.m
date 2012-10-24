//
//  EpomUtils.m
//  Epom iOS SDK
//
//  Created by Epom LTD on 9/6/12.
//

// system headers
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <mach/mach.h>

#import <CommonCrypto/CommonDigest.h>

#ifndef DO_NOT_NEED_NETWORK_UTILS
#import <SystemConfiguration/SCNetworkReachability.h>
#endif //DO_NOT_NEED_NETWORK_UTILS


//BPXL
#import "BPXLUUIDHandler/BPXLUUIDHandler.h"

@implementation ESUtilsPrivate

@synthesize adsServerUrl;

#ifndef DO_NOT_NEED_NETWORK_UTILS
+(BOOL)isNetworkReachable
{
	// Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	if (!didRetrieveFlags)
	{
		ES_LOG_ERROR(@"Could not recover network reachability flags.");
		return 0;
	}
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	NSURL *testURL = [NSURL URLWithString:@"http://www.google.com/"];
	NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
	
	NSURLConnection *testConnection = [[[NSURLConnection alloc] initWithRequest:testRequest delegate:nil] autorelease];
	return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
}
#endif //DO_NOT_NEED_NETWORK_UTILS

#pragma mark -- get mac address

+(NSString *)deviceMACAdressSHA1
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

+(NSString *)deviceUUID
{
	//return deviceMACAdressSHA1();
	return [BPXLUUIDHandler UUID];
}

static ESUtilsPrivate* _sharedESUtilsPrivate = nil;

+(ESUtilsPrivate*)shared
{
	@synchronized([ESUtilsPrivate class])
	{
		if (!_sharedESUtilsPrivate)
			_sharedESUtilsPrivate = [[self alloc] init];
		
		return _sharedESUtilsPrivate;
	}
	
	return nil;
}

-(id)init
{
	self = [super init];
	
	if (self != nil)
	{
		self.adsServerUrl = [NSString stringWithFormat:@"%@", EPOM_DEFAULT_URL];
	}
	
	return self;
}
@end
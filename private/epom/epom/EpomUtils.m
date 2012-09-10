//
//  EpomUtils.m
//  Epom iOS SDK
//
//  Created by Epom LTD on 9/6/12.
//
//

// system headers
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <mach/mach.h>

// frameworks
#import <SystemConfiguration/SCNetworkReachability.h>

// Epom
#import "EpomSettings.h"

BOOL isNetworkReachable()
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
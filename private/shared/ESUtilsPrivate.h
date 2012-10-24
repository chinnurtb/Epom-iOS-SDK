//
//  ESUtils.h
//	Epom iOS SDK
//
//  Created by Epom LTD on 9/6/12.
//
//

@interface ESUtilsPrivate : NSObject
{
	NSString *adsServerUrl;
}

#ifndef DO_NOT_NEED_NETWORK_UTILS
+(BOOL) isNetworkReachable;
#endif // DO_NOT_NEED_NETWORK_UTILS
+(NSString *)deviceMACAdressSHA1;
+(NSString *)deviceUUID;

+(ESUtilsPrivate *)shared;

@property (readwrite, retain) NSString *adsServerUrl;

@end

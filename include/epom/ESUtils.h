//
//  ESUtils.h
//  Epom SDK
//
//  Created by Epom LTD on 10/16/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	EpomSDK Utilities class (ESUtils)

#import "ESEnumerations.h"

/*
 	Utilities class for different auxiliary purposes
 */

@interface ESUtils : NSObject

// 	Changing log level of Epom SDK. Default value is ESVerboseErrorsOnly
+(void) setLogLevel:(ESVerboseType)verboseLevel;

// 	Changing epom advertisements server url with slash symbol at the end.
// Default value is @"http://api.epom.com/"
+(void) setAdsServerUrl:(NSString *)adsServerUrl;

@end
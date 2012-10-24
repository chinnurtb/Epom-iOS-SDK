//
//  ESUtils.m
//  Epom SDK
//
//  Created by Epom LTD on 10/16/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "epom/ESUtils.h"

@implementation ESUtils

+(void)setLogLevel:(ESVerboseType)verboseLevel
{
	[ESLogger shared].verboseType = verboseLevel;
}

+(void)setAdsServerUrl:(NSString *)adServerUrl
{
	[ESUtilsPrivate shared].adsServerUrl = adServerUrl;
}

@end

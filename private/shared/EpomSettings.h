//
//  EpomSettings.h
//  Epom SDK
//
//  Created by Epom LTD on 5/30/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "epom/ESEnumerations.h"

#define ESUtilsPrivate	ESUtilsForAds
#define ESLogger		ESLoggerForAds
#define BPXLUUIDHandler BPLXUDIDHandlerForAds

#import "EpomCommon.h"

#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIKit.h>

#define AD_MINIMAL_REQUEST_INTERVAL 		(5.0)
#define AD_DEFAULT_REQUEST_INTERVAL 		(15.0)

#define AD_TEMP_BANNER_BAN_TIME				(30.0)
#define AD_UPDATE_INTERVAL					(1.0)

#define AD_REQUEST_START_INTERVAL			(0.0)
#define AD_NETWORK_ERR_INTERVAL				(1.0)

#define HTTP_AD_REQUEST_TIMEOUT				(5.0)
#define HTTP_AD_IMPRESSION_TIMEOUT 			(5.0)
#define HTTP_AD_CLICK_TIMEOUT 				(5.0)

#define INTERSTITIAL_AD_MINIMAL_TIMEOUT 	(2.0)

#define ADNETWORK_TYPE_KEY 			@"AD_NETWORK"
#define ADNETWORK_PARAMETERS_KEY 	@"AD_NETWORK_PARAMETERS"
#define ADNETWORK_CONTENT_KEY		@"CONTENT"
#define ADNETWORK_BANNER_ID_KEY 	@"BANNER_ID"
#define ADNETWORK_PLACEMENT_ID_KEY 	@"PLACEMENT_ID"
#define ADNETWORK_CAMPAIGN_ID_KEY 	@"CAMPAIGN_ID"
#define ADNETWORK_COUNTRY_KEY 		@"COUNTRY"
#define ADNETWORK_HASH_KEY 			@"HASH"
#define ADNETWORK_SIGNATURE_KEY		@"SIGNATURE"

#define ADNETWORK_CONTENT_TYPE		@"CONTENT"

#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*x))
#define STATIC_ASSERT(test, msg) typedef char _static_assert_ ## msg [ ((test) ? 1 : -1) ]

static inline CGRect epom_view_size(ESBannerViewSizeType size)
{
	CGRect rects[] =
	{
		/* ESBannerViewSize320x50		*/	CGRectMake(0, 0, 320, 50),
		/* ESBannerViewSize768x90		*/	CGRectMake(0, 0, 768, 90),
	};
	
	STATIC_ASSERT(ARRAY_SIZE(rects) == ESBannerViewSizeTypeCount, INVALID_RECTS_ARRAY_SIZE);
	
	return rects[size];
}


static inline CGRect epom_screen_size()
{
	CGRect rect = [[UIScreen mainScreen] bounds];
	rect.origin.x = rect.origin.y = 0;
	
	if ([UIApplication sharedApplication].statusBarHidden == NO)
	{
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		
		float statusBarHeight = (statusBarFrame.size.height < statusBarFrame.size.width) ? statusBarFrame.size.height : statusBarFrame.size.width;
		
		rect.size.height -= statusBarHeight;
	}
	
	return rect;
}
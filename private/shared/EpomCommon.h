//
//  EpomCommon.h
//  Epom SDK
//
//  Created by Epom LTD on 10/12/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESUtilsPrivate.h"
#import "ESLogger.h"

#ifdef DEBUG
#	define ASSERT(x) assert(x)
#	define NOENTRY assert(false)
#else
#	define ASSERT(x)
#	define NOENTRY 
#endif

// urls section
#define EPOM_DEFAULT_URL		@"http://api.epom.com/"

#define AD_REQUEST_URL_FORMAT 		@"%@ads-api"
#define AD_IMPRESSION_URL_FORMAT 	@"%@impression.gif"
#define AD_CLICK_URL_FORMAT			@"%@click.gif"
#define APP_TRACK_URL_FORMAT		@"%@app/at?actionKey=%@&udid=%@"

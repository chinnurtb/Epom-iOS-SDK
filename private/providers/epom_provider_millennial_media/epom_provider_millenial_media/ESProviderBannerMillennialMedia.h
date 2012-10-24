//
//  ESProviderBannerMillenialMedia.h
//  ESProviderBannerMillenialMedia
//
//  Created by Epom LTD on 6/6/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProviderBanner.h"

#import "MMSDK/MMAdView.h"

@interface ESProviderBannerMillennialMedia : ESProviderBanner<MMAdDelegate>
{
	MMAdView *mmAdView;
}

@property (readwrite, retain) MMAdView *mmAdView;

@end

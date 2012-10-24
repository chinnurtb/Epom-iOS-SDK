//
//  ESProviderBannerInMobi.h
//  ESProviderBannerInMobi
//
//  Created by Epom LTD on 6/1/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBanner.h"

#import "InMobi/IMAdDelegate.h"

@class IMAdView;

@interface ESProviderBannerInMobi : ESProviderBanner<IMAdDelegate>
{
	IMAdView *imView;
}

@property (readwrite, retain) IMAdView *imView;

@end

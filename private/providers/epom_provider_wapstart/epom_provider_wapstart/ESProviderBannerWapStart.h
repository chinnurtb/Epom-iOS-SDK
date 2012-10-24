//
//  ESProviderBannerWapStart.h
//  ESProviderBannerWapStart
//
//  Created by Epom LTD on 8/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <ESProviderBanner.h>

#import "WPBannerView.h"

@interface ESProviderBannerWapStart : ESProviderBanner<WPBannerViewDelegate>
{
	WPBannerView *wpView;
}

@property (readwrite, retain) WPBannerView *wpView;

@end

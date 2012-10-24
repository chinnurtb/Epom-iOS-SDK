//
//  ESProviderBannerContent.h
//  Epom SDK
//
//  Created by Epom LTD on 6/1/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProviderBanner.h"
#import "ESContentBannerView.h"

@interface ESProviderBannerContent : ESProviderBanner<ESContentBannerViewDelegate>
{
	ESContentBannerView *bannerView;
}

@property (readwrite, retain) ESContentBannerView *bannerView;

@end

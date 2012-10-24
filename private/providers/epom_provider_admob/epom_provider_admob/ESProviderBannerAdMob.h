//
//  ESProviderBannerAdMob.h
//  ESProviderBannerAdMob
//
//  Created by Epom LTD on 5/30/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBanner.h"

#import "GoogleAdMobAds/GADBannerViewDelegate.h"

@class GADBannerView;

@interface ESProviderBannerAdMob : ESProviderBanner<GADBannerViewDelegate>
{
	GADBannerView *gadView;
}

@property (readwrite, retain) GADBannerView *gadView;

@end

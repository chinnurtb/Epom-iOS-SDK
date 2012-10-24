//
//  ESProviderBannerMOceanBased.h
//  ESProviderBannerMOceanBased
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBanner.h"

#import "mOcean/Classes/Public/MASTAdDelegate.h"

@class MASTAdView;

@interface ESProviderBannerMOceanBased : ESProviderBanner<MASTAdViewDelegate>
{
	MASTAdView *mastView;
}

@property (readwrite, retain) MASTAdView *mastView;

- (NSString *)adServerURL;
- (NSString *)adNetworkName;

@end

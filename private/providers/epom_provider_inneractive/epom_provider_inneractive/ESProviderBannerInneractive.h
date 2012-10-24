//
//  ESProviderBannerInneractive.h
//  ESProviderBannerInneractive
//
//  Created by Epom LTD on 6/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProviderBanner.h"
#import "InneractiveAd/InneractiveAd.h"

@class UIView;

@interface ESProviderBannerInneractive : ESProviderBanner<InneractiveAdDelegate>
{
	InneractiveAd *iaView;
}

@property (readwrite, retain) InneractiveAd *iaView;

@end

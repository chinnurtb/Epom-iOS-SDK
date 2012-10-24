//
//  ESProviderBannerTapIt.h
//  ESProviderBannerTapIt
//
//  Created by Epom LTD on 7/2/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import <ESProviderBanner.h>

#import "TapIt_iPhone_SDK/headers/TapIt.h"

@interface ESProviderBannerTapIt : ESProviderBanner<TapItBannerAdViewDelegate>
{
	TapItBannerAdView *tapItView;
	BOOL actionBegin;
}

@property (readwrite, retain) TapItBannerAdView *tapItView;

@end

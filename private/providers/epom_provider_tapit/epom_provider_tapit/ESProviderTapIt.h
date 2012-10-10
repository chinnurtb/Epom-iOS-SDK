//
//  ESProviderTapIt.h
//  ESProviderTapIt
//
//  Created by Epom LTD on 7/2/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import <ESProvider.h>

#import "TapIt_iPhone_SDK/headers/TapIt.h"

@interface ESProviderTapIt : ESProvider<TapItBannerAdViewDelegate>
{
	TapItBannerAdView *tapItView;
}

@property (readwrite, retain) TapItBannerAdView *tapItView;

@end

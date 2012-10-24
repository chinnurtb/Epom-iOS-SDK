//
//  ESProviderInterstitialTapIt.h
//  ESProviderInterstitialTapIt
//
//  Created by Epom LTD on 7/2/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import <ESProviderInterstitial.h>

#import "TapIt_iPhone_SDK/headers/TapIt.h"

@interface ESProviderInterstitialTapIt : ESProviderInterstitial<TapItInterstitialAdDelegate>
{
	TapItInterstitialAd *tapItView;
}

@property (readwrite, retain) TapItInterstitialAd *tapItView;

@end

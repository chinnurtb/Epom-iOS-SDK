//
//  ESProviderInterstitialMillenialMedia.h
//  ESProviderInterstitialMillenialMedia
//
//  Created by Epom LTD on 10/18/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitial.h"

#import "MMSDK/MMAdView.h"

@class UIViewController;

@interface ESProviderInterstitialMillennialMedia : ESProviderInterstitial<MMAdDelegate>

@property (readwrite, retain) MMAdView *mmAdView;
@property (readwrite, retain) UIViewController *rootViewController;

@end

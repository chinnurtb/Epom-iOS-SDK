//
//  ESProviderInterstitialSmaato.h
//  ESProviderInterstitialSmaato
//
//  Created by Epom LTD on 9/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitial.h"

#import "iSoma/SOMAFullscreenBanner.h"
#import "iSoma/SOMABannerViewDelegate.h"

@class UIViewController, SOMAFullScreenBannerLocal;

@interface ESProviderInterstitialSmaato : ESProviderInterstitial<SOMABannerViewDelegate, SOMAAdListenerProtocol>
{
	SOMAFullScreenBannerLocal *interstitialView;
}

@property (readwrite, retain) SOMAFullScreenBannerLocal *interstitialView;
@property (readwrite, retain) UIViewController *parentViewController;
@end

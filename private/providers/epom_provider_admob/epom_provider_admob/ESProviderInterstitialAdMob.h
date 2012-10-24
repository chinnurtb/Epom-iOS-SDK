//
//  ESProviderInterstitialAdMob.h
//  ESProviderInterstitialAdMob
//
//  Created by Epom LTD on 10/18/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import "ESProviderInterstitial.h"

#import "GoogleAdMobAds/GADInterstitialDelegate.h"

@class GADInterstitial;

@interface ESProviderInterstitialAdMob : ESProviderInterstitial<GADInterstitialDelegate>

@property (readwrite, retain) GADInterstitial *gadInterstitial;

@end

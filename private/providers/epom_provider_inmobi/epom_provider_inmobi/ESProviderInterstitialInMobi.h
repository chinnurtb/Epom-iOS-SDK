//
//  ESProviderimInterstitialInMobi.h
//  ESProviderIMAdInterstitialInMobi
//
//  Created by Epom LTD on 10/18/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitial.h"

#import "InMobi/IMAdInterstitialDelegate.h"

@class IMAdInterstitial;

@interface ESProviderInterstitialInMobi : ESProviderInterstitial<IMAdInterstitialDelegate>

@property (readwrite, retain) IMAdInterstitial *imInterstitial;

@end

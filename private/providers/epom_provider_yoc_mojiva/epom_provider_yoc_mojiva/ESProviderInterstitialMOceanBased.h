//
//  ESProviderInterstitialMOceanBased.h
//  ESProviderInterstitialMOceanBased
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitial.h"

#import "mOcean/Classes/Public/MASTAdDelegate.h"

@class MASTAdView, UIViewController;

@interface ESProviderInterstitialMOceanBased : ESProviderInterstitial<MASTAdViewDelegate>
{
}
@property (readwrite, retain) MASTAdView *mastView;
@property (readwrite, retain) UIViewController *parentController;


- (NSString *)adServerURL;
- (NSString *)adNetworkName;

@end

//
//  epom_provider_iad.h
//  epom_provider_iad
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitial.h"

#import <iAd/ADInterstitialAd.h>


@interface ESProviderInterstitialIAd : ESProviderInterstitial<ADInterstitialAdDelegate>
{
	ADInterstitialAd *adView;
}

@property (readwrite, retain) ADInterstitialAd *adView;

@end

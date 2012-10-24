//
//  ESProviderInterstitialContent.h
//  Epom SDK
//
//  Created by Epom LTD on 6/1/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitial.h"
#import "ESContentInterstitialView.h"

@interface ESProviderInterstitialContent : ESProviderInterstitial<ESContentInterstitialViewDelegate>
{
	ESContentInterstitialView *interstitialView;
}

@property (readwrite, retain) ESContentInterstitialView *interstitialView;

@end

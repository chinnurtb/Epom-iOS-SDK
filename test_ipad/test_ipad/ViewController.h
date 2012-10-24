//
//  ViewController.h
//  test_ipad
//
//  Created by Epom LTD on 5/28/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "epom/ESBannerViewDelegate.h"
#import "epom/ESInterstitialViewDelegate.h"

@interface ViewController : UIViewController<ESBannerViewDelegate, ESInterstitialViewDelegate>
{
	ESBannerView *esBannerView;
	ESInterstitialView *esInterstitialView;
	
	IBOutlet UIButton *btnShowInterstitial;

}

@property (readwrite, retain) ESBannerView *esBannerView;
@property (readwrite, retain) ESInterstitialView *esInterstitialView;

-(IBAction)showInterstitialAd:(id)sender;

@end

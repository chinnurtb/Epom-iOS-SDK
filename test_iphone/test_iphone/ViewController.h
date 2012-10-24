//
//  ViewController.h
//  test_iphone
//
//  Created by Epom LTD on 5/28/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "epom/ESBannerViewDelegate.h"
#import "epom/ESInterstitialViewDelegate.h"

@class ESBannerView, ESInterstitialView;

@interface ViewController : UIViewController<ESBannerViewDelegate, ESInterstitialViewDelegate>
{
	IBOutlet UIButton *btnShowInterstitial;
}

-(IBAction)showInterstitialAd:(id)sender;

@end

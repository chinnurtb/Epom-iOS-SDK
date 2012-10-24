//
//  ESContentInterstitialView.h
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import "ESContentViewBase.h"

#import "ESExpandedContentBannerViewController.h"

#import "ESContentInterstitialViewDelegate.h"

@class ESContentBannerExternalExpandedView;

@interface ESContentInterstitialView : ESContentViewBase<ESContentViewBaseDerivedProtocol>
{
	// view controller for expanded ad
	ESExpandedContentBannerViewController *expandedViewController_;

	// delegate
	id<ESContentInterstitialViewDelegate> delegate_;
}

@property (readwrite, assign) id<ESContentInterstitialViewDelegate> interstitialViewDelegate;

- (id)init;
- (void)presentWithModalViewController:(UIViewController *)controller;

@end

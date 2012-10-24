//
//  ESContentBannerView.h
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import "ESContentViewBase.h"

#import "ESExpandedContentBannerViewController.h"

#import "ESContentBannerViewDelegate.h"
#import "ESContentBannerExternalExpandedViewDelegate.h"

#import "../Utilities/ESDownloader.h"

@class ESContentBannerExternalExpandedView;

@interface ESContentBannerView : ESContentViewBase<ESContentViewBaseDerivedProtocol,
															ESDownloaderDelegate,
															ESContentBannerExternalExpandedViewDelegate>
{
	// external expanded banner data downloader for two-part ads
	ESDownloader *externalBannerDownloader_;
	ESContentBannerExternalExpandedView *externalBannerView_;
	
	// view controller for expanded ad
	ESExpandedContentBannerViewController *expandedViewController_;
	UIViewController *modalViewController_;

	// delegate
	id<ESContentBannerViewDelegate> delegate_;
}

@property (readwrite, assign) id<ESContentBannerViewDelegate> bannerViewDelegate;

- (id)initWithFrame:(CGRect)frame modalViewController:(UIViewController *)controller;

@end

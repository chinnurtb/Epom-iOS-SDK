//
//  ESProviderWapStart.h
//  ESProviderWapStart
//
//  Created by Epom LTD on 8/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <ESProvider.h>
#import <ESContentWebViewController.h>

#import "WapStart/src/WPBannerView.h"

@interface ESProviderWapStart : ESProvider<WPBannerViewDelegate, ESContentWebViewControllerDelegate>
{
	WPBannerView *wpView;
}

@property (readwrite, retain) WPBannerView *wpView;

@end

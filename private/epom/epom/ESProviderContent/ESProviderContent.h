//
//  ESProviderContent.h
//  Epom SDK
//
//  Created by Epom LTD on 6/1/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProvider.h"
#import "ESContentBannerView.h"

@interface ESProviderContent : ESProvider<ESContentBannerViewDelegate>
{
	ESContentBannerView *bannerView;
}

@property (readwrite, retain) ESContentBannerView *bannerView;

@end

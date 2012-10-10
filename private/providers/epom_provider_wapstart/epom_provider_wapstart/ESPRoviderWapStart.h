//
//  ESProviderWapStart.h
//  ESProviderWapStart
//
//  Created by Epom LTD on 8/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <ESProvider.h>

#import "WPBannerView.h"

@interface ESProviderWapStart : ESProvider<WPBannerViewDelegate>
{
	WPBannerView *wpView;
}

@property (readwrite, retain) WPBannerView *wpView;

@end

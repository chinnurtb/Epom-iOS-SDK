//
//  ESProviderBannerSmaato.h
//  ESProviderBannerSmaato
//
//  Created by Epom LTD on 9/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBanner.h"

#import "iSoma/SOMABannerView.h"
#import "iSoma/SOMABannerViewDelegate.h"

@interface ESProviderBannerSmaato : ESProviderBanner<SOMABannerViewDelegate, SOMAAdListenerProtocol>
{
	SOMABannerView *bannerView;
}

@property (readwrite, retain) SOMABannerView *bannerView;

@end

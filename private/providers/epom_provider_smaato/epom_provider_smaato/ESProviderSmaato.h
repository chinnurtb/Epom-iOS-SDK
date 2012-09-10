//
//  ESProviderSmaato.h
//  ESProviderSmaato
//
//  Created by Epom LTD on 9/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProvider.h"

#import "iSoma/SOMABannerView.h"
#import "iSoma/SOMABannerViewDelegate.h"

@interface ESProviderSmaato : ESProvider<SOMABannerViewDelegate, SOMAAdListenerProtocol>
{
	SOMABannerView *bannerView;
}

@property (readwrite, retain) SOMABannerView *bannerView;

@end

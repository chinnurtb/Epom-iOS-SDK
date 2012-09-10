//
//  epom_provider_iad.h
//  epom_provider_iad
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProvider.h"

#import <iAd/AdBannerView.h>


@interface ESProviderIAd : ESProvider<ADBannerViewDelegate>
{
	ADBannerView *adView;
	BOOL leaveApp;
}

@property (readwrite, retain) ADBannerView *adView;

@end

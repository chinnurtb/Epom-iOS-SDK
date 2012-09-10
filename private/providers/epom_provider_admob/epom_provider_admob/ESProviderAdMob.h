//
//  ESProviderAdMob.h
//  ESProviderAdMob
//
//  Created by Epom LTD on 5/30/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProvider.h"

#import "GoogleAdMobAds/GADBannerViewDelegate.h"

@class GADBannerView;

@interface ESProviderAdMob : ESProvider<GADBannerViewDelegate>
{
	GADBannerView *gadView;
}

@property (readwrite, retain) GADBannerView *gadView;

@end

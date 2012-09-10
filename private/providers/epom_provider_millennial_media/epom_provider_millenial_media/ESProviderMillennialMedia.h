//
//  ESProviderMillenialMedia.h
//  ESProviderMillenialMedia
//
//  Created by Epom LTD on 6/6/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProvider.h"

#import "MMSDK/MMAdView.h"

@interface ESProviderMillennialMedia : ESProvider<MMAdDelegate>
{
	MMAdView *mmAdView;
}

@property (readwrite, retain) MMAdView *mmAdView;

@end

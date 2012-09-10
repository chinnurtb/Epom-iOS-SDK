//
//  ESProviderInMobi.h
//  ESProviderInMobi
//
//  Created by Epom LTD on 6/1/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProvider.h"

#import "InMobi/IMAdDelegate.h"

@class IMAdView;

@interface ESProviderInMobi : ESProvider<IMAdDelegate>
{
	IMAdView *imView;
}

@property (readwrite, retain) IMAdView *imView;

@end

//
//  ESProviderInneractive.h
//  ESProviderInneractive
//
//  Created by Epom LTD on 6/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProvider.h"
#import "InneractiveAd/include/InneractiveAd.h"

@class UIView;

@interface ESProviderInneractive : ESProvider<InneractiveAdDelegate>
{
	InneractiveAd *iaView;
}

@property (readwrite, retain) InneractiveAd *iaView;

@end

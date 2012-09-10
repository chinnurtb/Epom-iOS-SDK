//
//  ESProviderMOceanBased.h
//  ESProviderMOceanBased
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProvider.h"

#import "mOcean/Classes/Public/MASTAdDelegate.h"

@class MASTAdView;

@interface ESProviderMOceanBased : ESProvider<MASTAdViewDelegate>
{
	MASTAdView *mastView;
}

@property (readwrite, retain) MASTAdView *mastView;

- (NSString *)adServerURL;
- (NSString *)adNetworkName;

@end

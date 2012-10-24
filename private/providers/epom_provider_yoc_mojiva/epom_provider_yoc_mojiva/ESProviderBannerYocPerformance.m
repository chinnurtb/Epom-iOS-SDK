//
//  ESProviderBannerYocPerformance.m
//  ESProviderBannerYocPerformance
//
//  Created by Epom LTD on 6/6/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBannerYocPerformance.h"

@implementation ESProviderBannerYocPerformance

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate_
{
	return [super initWithParameters:params sizeType: size delegate:delegate_];
}

- (NSString *)adServerURL
{
	return @"http://ads.mo.yoc-adserver.com/ad";
}

- (NSString *)adNetworkName
{
	return @"YocPerformance";
}

@end
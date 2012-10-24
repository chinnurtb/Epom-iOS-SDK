//
//  ESProviderInterstitialYocPerformance.m
//  ESProviderInterstitialYocPerformance
//
//  Created by Epom LTD on 6/6/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialYocPerformance.h"

@implementation ESProviderInterstitialYocPerformance

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	return [super initWithParameters:params delegate:delegate_];
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
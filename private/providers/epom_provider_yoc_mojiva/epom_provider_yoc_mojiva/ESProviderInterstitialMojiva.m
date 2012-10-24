//
//  ESProviderInterstitialMojiva.m
//  ESProviderInterstitialMojiva
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderInterstitialMojiva.h"

@implementation ESProviderInterstitialMojiva

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate_
{
	return [super initWithParameters:params delegate:delegate_];
}

- (NSString *)adServerURL
{
	return @"http://ads.mojiva.com/ad";
}

- (NSString *)adNetworkName
{
	return @"Mojiva";
}

@end
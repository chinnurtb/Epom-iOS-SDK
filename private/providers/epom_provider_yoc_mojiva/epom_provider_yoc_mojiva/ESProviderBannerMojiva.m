//
//  ESProviderBannerMojiva.m
//  ESProviderBannerMojiva
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBannerMojiva.h"

@implementation ESProviderBannerMojiva

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate_
{
	return [super initWithParameters:params sizeType: size delegate:delegate_];
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
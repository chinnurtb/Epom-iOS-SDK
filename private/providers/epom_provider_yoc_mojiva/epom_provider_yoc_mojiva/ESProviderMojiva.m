//
//  ESProviderMojiva.m
//  ESProviderMojiva
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderMojiva.h"

@implementation ESProviderMojiva

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
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
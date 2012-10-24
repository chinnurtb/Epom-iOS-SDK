//
//  ESNumber.m
//  Epom SDK
//
//  Created by Epom LTD on 6/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESNumber.h"

@implementation ESNumber

@synthesize value;

+ (id) numberWithDouble:(double)v
{
	return [[[ESNumber alloc] initWithDouble:v] autorelease];
}

- (id) initWithDouble:(double)v
{
	self = [super init];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.value = v;
	
	return self;
}

@end

//
//  ESLogger.m
//  Epom SDK
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESLogger.h"

@implementation ESLogger

@synthesize verboseType;

static ESLogger* _shared = nil;

+(ESLogger*)shared
{
	@synchronized([ESLogger class])
	{
		if (!_shared)
			[[self alloc] init];
		
		return _shared;
	}
	
	return nil;
}

+(id)alloc
{
	@synchronized([ESLogger class])
	{
		NSAssert(_shared == nil, @"Attempted to allocate a second instance of a singleton.");
		_shared = [super alloc];
		return _shared;
	}
	
	return nil;
}

-(id)init 
{
	self = [super init];
	
	if (self == nil)
	{
		return nil;
	}
		
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)logType:(ESLoggerMessageType)type format:(NSString *)format, ...
{
	@synchronized(self)
	{
		if (self.verboseType <= type)
		{
			NSString *value = nil;
			{
				va_list args;
				va_start(args, format);
				value = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
				va_end(args);				
			}
			
			NSString *typeValues[ESLoggerMessageTypeCount] = 
			{
				/*ESLoggerMessageInfo	*/	@"info",
				/*ESLoggerMessageError	*/	@"error",
			};
									
			NSLog(@"Epom %@: %@", typeValues[type], value);
		}
	}
}

@end

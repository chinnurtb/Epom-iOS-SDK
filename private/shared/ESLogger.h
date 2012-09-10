//
//  ESLogger.h
//  Epom SDK
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "epom/ESEnumerations.h"

typedef enum
{
	ESLoggerMessageInfo 	= 0,
	ESLoggerMessageError,

	ESLoggerMessageTypeCount // for inner usage	
} ESLoggerMessageType;


@interface ESLogger : NSObject
{
	ESVerboseType verboseType;
}

@property (readwrite, assign) ESVerboseType verboseType;

+(ESLogger*)shared;

-(void)logType:(ESLoggerMessageType)type format:(NSString *)format, ...;


@end

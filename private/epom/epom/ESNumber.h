//
//  ESNumber.h
//  Epom SDK
//
//  Created by Epom LTD on 6/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESNumber : NSObject
{
	double value;
}

+ (id) numberWithDouble:(double)v;
- (id) initWithDouble:(double)v;

@property (readwrite, assign) double value;

@end

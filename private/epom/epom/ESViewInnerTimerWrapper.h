//
//  ESViewTimerWrapper.h
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESViewInner;

@interface ESViewInnerTimerWrapper : NSObject
{
	NSTimer *timer;
	ESViewInner *esView;
}

-(id)initWithESViewInner:(ESViewInner *)view;

-(void)stop;

@end

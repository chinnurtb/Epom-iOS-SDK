//
//  ESViewTimerWrapper.h
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESBannerInner;

@interface ESBannerInnerTimerWrapper : NSObject
{
	NSTimer *timer;
	ESBannerInner *esBannerInner;
}

-(id)initWithESBannerInner:(ESBannerInner *)view;

-(void)stop;

@end

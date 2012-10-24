//
//  ESBannerInner.h
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "epom/ESBannerView.h"

#import "ESProviderBannerDelegate.h"

@class ESBannerInnerTimerWrapper, ESBannerView;

@interface ESBannerInner : NSObject<NSURLConnectionDelegate, ESProviderBannerDelegate>

+ (UInt32) numAliveViews;

// initalizer

- (id)initWithParent:(ESBannerView*)parent ID:(NSString*)ID sizeType:(ESBannerViewSizeType)size modalViewController:(UIViewController *)controller
	 useLocation:(BOOL)doUseLocation testMode:(BOOL)inTestMode;

// updater
- (void)onUpdate;

// properties

@property (readwrite, assign) NSTimeInterval refreshTimeInterval;

@end

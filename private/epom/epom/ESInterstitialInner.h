//
//  ESInterstitialInner.h
//  Epom SDK
//
//  Created by Epom LTD on 10/17/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "epom/ESInterstitialView.h"

#import "ESProviderInterstitialDelegate.h"

@interface ESInterstitialInner : NSObject<NSURLConnectionDelegate, ESProviderInterstitialDelegate>

// initalizer
- (id)initWithParent:(ESInterstitialView*)parent ID:(NSString*)ID
	 useLocation:(BOOL)doUseLocation testMode:(BOOL)inTestMode;

- (void)reload;

- (void)presentWithViewController:(UIViewController *)viewController;

- (void)presentAsStartupScreenWithWindow:(UIWindow *)window defaultImage:(UIImage *)image;

// properties
@property (readwrite, assign) NSTimeInterval loadTimeout;
@property (readwrite, assign) ESInterstitialViewStateType state;

@end

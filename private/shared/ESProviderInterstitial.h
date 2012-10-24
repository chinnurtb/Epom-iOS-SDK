//
//  ESProviderInterstitial.h
//  Epom SDK
//
//  Created by Epom LTD on 10/17/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "epom/ESEnumerations.h"

#import "ESProviderInterstitialDelegate.h"

@class UIViewController;

@interface ESProviderInterstitial : NSObject
{
	id<ESProviderInterstitialDelegate> delegate;
	NSDictionary *responseParameters;
}

@property (readwrite, assign) id<ESProviderInterstitialDelegate> delegate;
@property (readwrite, retain) NSDictionary *responseParameters;

+ (id)providerInterstitialFromClass:(Class)cls parameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate;
+ (BOOL)initializeSystem;

- (id)initWithParameters:(NSDictionary *)params delegate:(id<ESProviderInterstitialDelegate>)delegate;

- (void)presentWithViewController:(UIViewController *)viewController;
@end

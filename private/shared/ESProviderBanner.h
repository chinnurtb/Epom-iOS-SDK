//
//  ESProviderBanner.h
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "epom/ESEnumerations.h"

#import "ESProviderBannerDelegate.h"

@class UIView;
@class UIViewController;

@interface ESProviderBanner : NSObject
{
	id<ESProviderBannerDelegate> delegate;
	ESBannerViewSizeType sizeType;
	NSDictionary *responseParameters;
}

@property (readwrite, assign) id<ESProviderBannerDelegate> delegate;
@property (readwrite, assign) ESBannerViewSizeType sizeType;
@property (readwrite, retain) NSDictionary *responseParameters;
@property (readonly, getter=getView) UIView *view;

+ (id)providerBannerFromClass:(Class)cls parameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate;
+ (BOOL)initializeSystem;
+ (UInt32)numAliveProviders;

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESBannerViewSizeType)size delegate:(id<ESProviderBannerDelegate>)delegate;

// pure method. Has to be reimplemented in derived classes
- (UIView*) getView;
@end

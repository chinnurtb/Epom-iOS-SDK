//
//  ESProvider.h
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "epom/ESEnumerations.h"

#include "ESProviderDelegateProtocol.h"

@class UIView;
@class UIViewController;

@interface ESProvider : NSObject
{
	id<ESProviderDelegate> delegate;	
	ESViewSizeType sizeType;
	NSDictionary *responseParamaters;
}

@property (readwrite, assign) id<ESProviderDelegate> delegate;
@property (readwrite, assign) ESViewSizeType sizeType;
@property (readwrite, retain) NSDictionary *responseParameters;
@property (readonly, getter=getView) UIView *view;

+ (id)providerFromClass:(Class)cls parameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate;
+ (BOOL)initializeSystem;
+ (UInt32)numAliveProviders;

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate;

// pure method. Has to be reimplemented in derived classes
- (UIView*) getView;
@end

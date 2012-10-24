//
//  ESProviderInterstitialJumpTap.h
//  ESProviderInterstitialJumpTap
//
//  Created by Epom LTD on 10/18/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProviderInterstitial.h"

#import "JTIPHONE/JTAdWidget.h"

@interface ESProviderInterstitialJumpTap : ESProviderInterstitial<JTAdWidgetDelegate>

@property (readwrite, retain) JTAdWidget *jtView;
@property (readwrite, retain) NSString *publisherID;
@property (readwrite, retain) NSString *spotID;
@property (readwrite, retain) NSString *siteID;

@property (readwrite, assign) UIViewController *parentViewController;

@end

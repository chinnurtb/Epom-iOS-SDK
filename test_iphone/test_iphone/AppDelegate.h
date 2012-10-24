//
//  AppDelegate.h
//  test_iphone
//
//  Created by Epom LTD on 5/28/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "epom/ESInterstitialView.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ESInterstitialViewDelegate>

@property (nonatomic, retain) UIWindow *window;

@end

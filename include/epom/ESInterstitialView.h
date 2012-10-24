//
//  ESInterstitialView.h
//  Epom SDK
//
//  Created by Epom LTD on 10/16/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	EpomSDK InterstitialView class (ESInterstitialView)

#import <UIKit/UIKit.h>

#import "ESEnumerations.h"
#import "ESInterstitialViewDelegate.h"


// Class for retrieving and visualising interstitial (full-screen) advertisements
@interface ESInterstitialView : NSObject

// delegate accessor
@property (readwrite, assign) id<ESInterstitialViewDelegate> delegate;

// return current interstitial state
@property (readonly) ESInterstitialViewStateType state;

// access interstitial load timeout. 0 means no timeout load interruption, minimum is 2 seconds. Default is 0.
@property (readwrite, assign) NSTimeInterval loadTimeout;

// initializes ESInterstitialView using string identifier of interstitial, optional user location use
// and test mode enabled. After initialization, view will try to load interstitial ad
-(id)initWithID:(NSString *)interstitialID useLocation:(BOOL)doUseLocation testMode:(BOOL)testMode;

// shows up interstitial view from view controller.
-(void)presentWithViewController:(UIViewController *)viewController;

// shows up interstitial view on application launch using application window and default image.
// For continue application work, users must listen delegate esInterstitialViewDidLeaveModalMode: message.
// BEWARE: for use only in application delegate's application:didFinishLaunchingWithOptions: method after
// main window makeKeyAndVisible call
-(void)presentAsStartupScreenWithWindow:(UIWindow *)window defaultImage:(UIImage *)image;

// loads another one interstitial ad. Do nothing if ESInterstitialView state is not
// ESInterstitialStateDone nor ESInterstitialStateFailed;
-(void)reload;

@end



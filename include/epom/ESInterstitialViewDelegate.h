//
//  ESInterstitialView.h
//  Epom SDK
//
//  Created by Epom LTD on 10/16/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	Delegate protocol for ESBannerView.

#import <Foundation/Foundation.h>

@class ESInterstitialView;

// Protocol for ESInterstitialView notifications

@protocol ESInterstitialViewDelegate<NSObject>

@optional

// Notification: Interstitial ad started loading. State is changed to ESInterstitialViewStateLoading.
-(void)esInterstitialViewDidStartLoadAd:(ESInterstitialView *)esInterstitialView;

// Notification: Interstitial ad failed to load. State is changed to ESInterstitialViewStateFailed.
// Error code/type is output to debug console
-(void)esInterstitialViewDidFailLoadAd:(ESInterstitialView *)esInterstitialView;

// Notification: Interstitial ad successfully loaded. State is changed to ESInterstitialViewStateReady.
-(void)esInterstitialViewDidLoadAd:(ESInterstitialView *)esInterstitialView;

// Notification: Interstitial ad starts to display ad. State is changed to ESInterstitialViewStateActive.
-(void)esInterstitialViewWillEnterModalMode:(ESInterstitialView *)esInterstitialView;

// Notification: Interstitial ad finished to display ad. State is changed to ESInterstitialViewStateDone.
-(void)esInterstitialViewDidLeaveModalMode:(ESInterstitialView *)esInterstitialView;

// Notification: User has interacted with ad provided by ESInterstitialView. Optional is application leaving to navigate to Safari, iTunes, etc.
-(void)esInterstitialViewUserInteraction:(ESInterstitialView *)esInterstitialView willLeaveApplication:(BOOL)yesOrNo;

@end

//
//  ESProviderInterstitialDelegate.h
//  Epom SDK
//
//  Created by Epom LTD on 10/17/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	This file is for inner usage. No documentation provided

#import <Foundation/Foundation.h>

@class ESProviderInterstitial;

@protocol ESProviderInterstitialDelegate<NSObject>

@required

#pragma mark -- ads callbacks
-(void)providerDidRecieveAd:(ESProviderInterstitial *)provider;
-(void)providerFailedToRecieveAd:(ESProviderInterstitial *)provider;

#pragma mark -- application lifetime notifications
-(void)providerViewWillEnterModalMode:(ESProviderInterstitial *)provider;
-(void)providerViewDidLeaveModalMode:(ESProviderInterstitial *)provider;
-(void)providerViewUserInteraction:(ESProviderInterstitial *)provider willLeaveApplication:(BOOL)yesOrNo;

#pragma mark -- settings access for providers
-(BOOL)inTestMode;

@end

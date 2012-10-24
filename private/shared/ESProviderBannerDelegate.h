//
//  ESProviderBannerDelegate.h
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	This file is for inner usage. No documentation provided

#import <Foundation/Foundation.h>

@class ESProviderBanner;
@class UIViewController;

@protocol ESProviderBannerDelegate<NSObject>

@required

#pragma mark -- ads callbacks
-(void)providerDidRecieveAd:(ESProviderBanner *)provider;
-(void)providerFailedToRecieveAd:(ESProviderBanner *)provider;
-(void)providerViewHasBeenClicked:(ESProviderBanner *)provider;

#pragma mark -- application lifetime notifications
-(void)providerViewWillEnterModalMode:(ESProviderBanner *)provider;
-(void)providerViewDidLeaveModalMode:(ESProviderBanner *)provider;
-(void)providerViewWillLeaveApplication:(ESProviderBanner *)provider;

#pragma mark -- settings access for providers
-(BOOL)inTestMode;
-(UIViewController*)screenPresentController; 

@end

//
//  ESBannerViewDelegateProtocol.h
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	Delegate protocol for ESBannerView.

#import <Foundation/Foundation.h>

@class ESBannerView;

// Protocol for ESBannerView notifications

@protocol ESBannerViewDelegate<NSObject>

@optional

// Notification: Ad provided by ESBannerView will be shown
-(void)esBannerViewWillShowAd:(ESBannerView *)esBannerView;

// Notification: Ad provided by ESBannerView is shown
-(void)esBannerViewDidShowAd:(ESBannerView *)esBannerView;

// Notification: Ad provided by ESBannerView has been tapped
-(void)esBannerViewAdHasBeenTapped:(ESBannerView *)esBannerView;

// Notification: Ad provided by ESBannerView will enter modal mode when opening embedded screen view controller
-(void)esBannerViewWillEnterModalMode:(ESBannerView *)esBannerView;

// Notification: Ad provided by ESBannerView did leave modal mode
-(void)esBannerViewDidLeaveModalMode:(ESBannerView *)esBannerView;

// Notification: Ad provided by ESBannerView causes to leave application to navigate to Safari, iTunes, etc.
-(void)esBannerViewWillLeaveApplication:(ESBannerView *)esBannerView;

@end

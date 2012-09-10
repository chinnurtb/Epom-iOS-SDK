//
//  ESProviderDelegateProtocol.h
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	This file is for inner usage. No documentation provided

#import <Foundation/Foundation.h>

@class ESProvider;
@class UIViewController;
@class CLLocation;

@protocol ESProviderDelegate<NSObject>

@required

#pragma mark -- ads callbacks
-(void)providerDidRecieveAd:(ESProvider *)provider;
-(void)providerFailedToRecieveAd:(ESProvider *)provider;
-(void)providerViewHasBeenClicked:(ESProvider *)provider;

#pragma mark -- application lifetime notifications
-(void)providerViewWillEnterModalMode:(ESProvider *)provider;
-(void)providerViewDidLeaveModalMode:(ESProvider *)provider;
-(void)providerViewWillLeaveApplication:(ESProvider *)provider;

#pragma mark -- settings access for providers
-(BOOL)inTestMode;
-(UIViewController*)screenPresentController; 
-(CLLocation *)currentLocation;

@end

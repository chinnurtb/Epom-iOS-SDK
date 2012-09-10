//
//  ESViewDelegateProtocol.h
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	Delegate protocol for ESView.

#import <Foundation/Foundation.h>

@class ESView;
@class UIViewController;

@protocol ESViewDelegate<NSObject>

@optional

/*
 Notification: Ad provided by ESView will be shown
 */
-(void)esViewWillShowAd:(ESView *)esView;

/*
 Notification: Ad provided by ESView is shown
 */
-(void)esViewDidShowAd:(ESView *)esView;

/*
 Notification: Ad provided by ESView has been tapped
 */
-(void)esViewAdHasBeenTapped:(ESView *)esView;

/*
	Notification: Ad provided by ESView will enter modal mode when opening embedded screen view controller
*/ 
-(void)esViewWillEnterModalMode:(ESView *)esView;

/* 
	Notification: Ad provided by ESView did leave modal mode 
*/
-(void)esViewDidLeaveModalMode:(ESView *)esView;

/*
	Notification: Ad provided by ESView causes to leave application to navigate to Safari, iTunes, etc.
*/ 
-(void)esViewWillLeaveApplication:(ESView *)esView;

@end

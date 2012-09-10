//
//
//  ESContentWebViewController.h
//  Epom SDK
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESContentWebViewController : UIViewController <UIWebViewDelegate> 
{
	UIWebView *webView;
	UIActivityIndicatorView *busyWebIcon;
	UIBarButtonItem *webForward;	
	UIToolbar *toolBar;
	id delegate;
}
@property (nonatomic,retain) id delegate;

- (void) showNoNetworkAlert;
- (IBAction) browseBack: (id) sender;
- (IBAction) browseForward: (id) sender;
- (IBAction) stopOrReLoadWeb: (id) sender;
- (IBAction) launchSafari: (id) sender;
- (void) loadBrowser: (NSURL *) url;
- (IBAction)done: (id)sender;

- (id) initWithControls;
@end

@protocol ESContentWebViewControllerDelegate
@optional
- (void) onDismissWebView:(BOOL)leaveApp;
@end
//
//  ESContentBannerViewBase.h
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import <UIKit/UIKit.h>

#import "ESContentWebViewController.h"
#import "ESLoggedWebView.h"

@class CLLocation;

@protocol ESContentBannerViewBaseDerivedProtocol;
#define ESContentBannerViewBaseDerived ESContentBannerViewBase<ESContentBannerViewBaseDerivedProtocol>

enum ESContentBannerViewState
{
	ESContentBannerViewStateUnknown = 0,
	
	ESContentBannerViewStateLoading,
	ESContentBannerViewStateDefault,
	ESContentBannerViewStateExpanded,
	ESContentBannerViewStateHidden,
	
	ESContentBannerViewStateSize
};

enum ESContentBannerViewPlacement
{
	ESContentBannerViewPlacementUnknown = 0,
	
	ESContentBannerViewPlacementInline,
	ESContentBannerViewPlacementInterstitial,
	
	ESContentBannerViewPlacementSize
};

struct ESContentBannerViewExpandProperties
{
	int width;
	int height;
	BOOL useCustomClose;
	BOOL isModal;
};


@interface ESContentBannerViewBase : ESLoggedWebView<UIWebViewDelegate, ESContentWebViewControllerDelegate>
{
	// root view controller
	UIViewController *modalViewController_;
	// javascript->Objective-C commands dictionary
	NSDictionary *nativeCommands_;
	// commands queue to process after setVisible(true)
	NSMutableArray *commandsAppearQueue_;
	// source content file, saved to temp folder
	NSString *sourceHTMLFilePath_;
		
	// current ad state variables
	BOOL autoexpandOnAppear_;
	enum ESContentBannerViewState state_;
	enum ESContentBannerViewPlacement placement_;
	struct ESContentBannerViewExpandProperties expandProperties_;
	
	ESContentBannerViewBaseDerived *derived_;
}

// methods

- (id)initWithFrame:(CGRect)frame modalViewController:(UIViewController *)controller expandProperties:(struct ESContentBannerViewExpandProperties *)expandProperties;
- (void)setDerived:(ESContentBannerViewBaseDerived *)derived;

- (void)loadContent:(NSString *)content;
- (void)closeExpandedView;

- (void)simulateMRAIDExpanding;
- (void)simulateMRAIDShrinking;

// properties
@property (readonly) enum ESContentBannerViewState state;
@property (readonly) enum ESContentBannerViewPlacement placement;
@property (readonly) struct ESContentBannerViewExpandProperties expandProperties;
@property (readonly, getter = rootViewController) UIViewController *rootViewController;
@end

// protocol for derived
@protocol ESContentBannerViewBaseDerivedProtocol

@required

- (void)onAdLoadError:(NSError *)error;
- (void)onAdLoadSuccess;
- (void)onAdHasBeenTapped;
- (void)onAdWillEnterModalMode;
- (void)onAdDidLeaveModalMode;
- (void)onAdWillLeaveApp;

- (CLLocation *)onGeoLocationRequest;

- (BOOL)onExpand:(NSString *)url;
- (void)onBeforeStateChangeFrom:(enum ESContentBannerViewState)stateBefore to:(enum ESContentBannerViewState)stateAfter;
- (void)onAfterStateChangeFrom:(enum ESContentBannerViewState)stateBefore to:(enum ESContentBannerViewState)stateAfter;
- (UIViewController *)onControllerForEmbeddedBrowserRequest;

@end

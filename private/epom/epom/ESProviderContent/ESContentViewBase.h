//
//  ESContentViewBase.h
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import <UIKit/UIKit.h>

#import "ESContentWebViewController.h"
#import "ESLoggedWebView.h"

@class CLLocation;

@protocol ESContentViewBaseDerivedProtocol;
#define ESContentViewBaseDerived ESContentViewBase<ESContentViewBaseDerivedProtocol>

typedef enum
{
	ESContentViewStateUnknown = 0,
	
	ESContentViewStateLoading,
	ESContentViewStateDefault,
	ESContentViewStateExpanded,
	ESContentViewStateHidden,
	
	ESContentViewStateSize
} ESContentViewState;

typedef enum
{
	ESContentViewPlacementInline = 0,
	ESContentViewPlacementInterstitial,
	
	ESContentViewPlacementSize
} ESContentViewPlacement;

typedef struct
{
	int width;
	int height;
	BOOL useCustomClose;
	BOOL isModal;
} ESContentViewExpandProperties;


@interface ESContentViewBase : ESLoggedWebView<UIWebViewDelegate, ESContentWebViewControllerDelegate>
{
	// javascript->Objective-C commands dictionary
	NSDictionary *nativeCommands_;
	// commands queue to process after setVisible(true)
	NSMutableArray *commandsAppearQueue_;
	// source content file, saved to temp folder
	NSString *sourceHTMLFilePath_;
		
	// current ad state variables
	ESContentViewState viewState_;
	ESContentViewPlacement viewPlacement_;
	ESContentViewExpandProperties expandProperties_;
	BOOL autoShow_;
	
	ESContentViewBaseDerived *derived_;
}

// methods

- (id)initWithFrame:(CGRect)frame
   expandProperties:(ESContentViewExpandProperties *)expandProperties
	 isInterstitial:(BOOL)isInterstitial
		   autoShow:(BOOL)autoShow;
- (void)setDerived:(ESContentViewBaseDerived *)derived;

- (void)loadContent:(NSString *)content;
- (void)show;
- (void)close;

- (void)simulateMRAIDExpanding;
- (void)simulateMRAIDShrinking;

// properties
@property (readonly) ESContentViewState viewState;
@property (readonly) ESContentViewPlacement viewPlacement;
@property (readonly) ESContentViewExpandProperties expandProperties;
@end

// protocol for derived
@protocol ESContentViewBaseDerivedProtocol
@required
- (void)onAdLoadError:(NSError *)error;
- (void)onAdLoadSuccess;
- (void)onAdWillEnterModalMode;
- (void)onAdDidLeaveModalMode;
- (void)onUserInteractionWithWillLeaveApp:(BOOL)willLeaveApp;
- (BOOL)onExpand:(NSString *)url;
- (void)onBeforeStateChangeFrom:(ESContentViewState)stateBefore to:(ESContentViewState)stateAfter;
- (void)onAfterStateChangeFrom:(ESContentViewState)stateBefore to:(ESContentViewState)stateAfter;
- (UIViewController *)onControllerForEmbeddedBrowserRequest;

- (BOOL)treatExpandAsUserInteraction;
@end

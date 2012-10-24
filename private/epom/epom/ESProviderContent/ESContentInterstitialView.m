//
//  ESContentInterstitialView.m
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import "ESContentInterstitialView.h"

#import "EpomSettings.h"

@interface ESContentInterstitialView ()

// view controller for expanded ad
@property (readwrite, retain) ESExpandedContentBannerViewController *expandedViewController;
// root view controller
@property (readwrite, assign) UIViewController *rootViewController;
@end

@implementation ESContentInterstitialView

@synthesize rootViewController;

@synthesize interstitialViewDelegate = delegate_;

@synthesize expandedViewController = expandedViewController_;

- (id)init
{
	CGRect rect = epom_screen_size();
	ESContentViewExpandProperties expandProperties = {rect.size.width, rect.size.height, NO, YES};
	
	self = [super initWithFrame:epom_screen_size() expandProperties:&expandProperties isInterstitial:YES autoShow:NO];
	[super setDerived:self];
	
	if (self == nil)
	{
		return nil;
	}
	
	return self;
}

- (void)dealloc
{
	[self.expandedViewController hide];
	self.expandedViewController = nil;
	
	[super setDerived:nil];
	[super dealloc];
}

- (void)presentWithModalViewController:(UIViewController *)controller
{
	self.rootViewController = controller;
	[self show];
}

#pragma mark -- ESContentBannerViewBaseDerivedProtocol implementation

- (void)onAdLoadError:(NSError *)error
{
	[self.interstitialViewDelegate didFailToRecieveAdWithError:error];
}

- (void)onAdLoadSuccess
{
	[self.interstitialViewDelegate didRecieveAd];
}

- (void)onUserInteractionWithWillLeaveApp:(BOOL)willLeaveApp
{
	[self.interstitialViewDelegate didPerformUserInteraction:willLeaveApp];
}

- (void)onAdWillEnterModalMode
{
}

- (void)onAdDidLeaveModalMode
{
}

- (BOOL)onExpand:(NSString *)url
{
	if (url == nil)
	{
		return YES;
	}
	
	NOENTRY;
	
	return NO;
}

- (void)onBeforeStateChangeFrom:(ESContentViewState)stateBefore to:(ESContentViewState)stateAfter
{
}

- (void)onAfterStateChangeFrom:(ESContentViewState)stateBefore to:(ESContentViewState)stateAfter
{
	if (stateBefore != ESContentViewStateHidden && stateAfter == ESContentViewStateHidden)
	{
		[self.expandedViewController hide];
		self.expandedViewController = nil;
		
		[self.interstitialViewDelegate didLeaveModalMode];
		
	}
	
	if (stateBefore != ESContentViewStateExpanded && stateAfter == ESContentViewStateExpanded)
	{
		self.expandedViewController = [[[ESExpandedContentBannerViewController alloc] initAndShowWithBannerView:self
																							   parentController:self.rootViewController
																										   size:CGSizeMake(expandProperties_.width, expandProperties_.height)
																							  customCloseButton:expandProperties_.useCustomClose] autorelease];
		[self.interstitialViewDelegate willEnterModalMode];
	}	
}

- (UIViewController *)onControllerForEmbeddedBrowserRequest
{
	return self.expandedViewController;
}

- (BOOL)treatExpandAsUserInteraction
{
	return NO;
}
@end


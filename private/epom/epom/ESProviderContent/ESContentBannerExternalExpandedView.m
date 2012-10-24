//
//  ESContentBannerExternalExpandedView.m
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import "ESContentBannerExternalExpandedView.h"
#import "EpomSettings.h"

@interface ESContentBannerExternalExpandedView ()

// view controller for expanded ad
@property (readwrite, assign) UIViewController *rootViewController;
@property (readwrite, retain) ESExpandedContentBannerViewController *expandedViewController;

@end

@implementation ESContentBannerExternalExpandedView

@synthesize bannerViewDelegate = delegate_;
@synthesize expandedBannerViewDelegate = expandedDelegate_;
@synthesize rootViewController = rootViewController_;
@synthesize expandedViewController = expandedViewController_;

- (id)initWithExpandProperties:(ESContentViewExpandProperties)expandProperties
					   content:(NSString *)content
		   modalViewController:(UIViewController *)controller
				  viewDelegate:(id<ESContentBannerViewDelegate>)delegate
		  expandedViewDelegate:(id<ESContentBannerExternalExpandedViewDelegate>) expandedViewDelegate
{
	self = [super initWithFrame:CGRectMake(0, 0, expandProperties.width, expandProperties.width)
			   expandProperties:&expandProperties
				 isInterstitial:YES
					   autoShow:YES];
	
	[super setDerived:self];
	
	if (self == nil)
	{
		return nil;
	}
	self.rootViewController = controller;
	self.bannerViewDelegate = delegate;
	self.expandedBannerViewDelegate = expandedViewDelegate;
	
	[self loadContent:content];
	
	return self;
}

- (void)dealloc
{
	self.bannerViewDelegate = nil;
	self.expandedBannerViewDelegate = nil;
	
	self.expandedViewController = nil;
	
	[super setDerived:nil];
	[super dealloc];
}

#pragma mark -- ESContentBannerViewBaseDerivedProtocol implementation

- (void)onAdLoadError:(NSError *)error
{
	[self.expandedBannerViewDelegate didFailLoadingWithError:error];
}

- (void)onAdLoadSuccess
{
	[self.expandedBannerViewDelegate didFinishLoading];
	
	[self showWithController];
}

- (void)onAdWillEnterModalMode
{
}

- (void)onAdDidLeaveModalMode
{
}

- (void)onUserInteractionWithWillLeaveApp:(BOOL)willLeaveApp
{
	if (willLeaveApp)
	{
		[self.bannerViewDelegate willLeaveApplication];
	}
}

- (BOOL)onExpand:(NSString *)url
{
	return YES;
}

- (void)onBeforeStateChangeFrom:(ESContentViewState)stateBefore to:(ESContentViewState)stateAfter
{	
}

- (void)onAfterStateChangeFrom:(ESContentViewState)stateBefore to:(ESContentViewState)stateAfter
{
	if ((stateBefore == ESContentViewStateExpanded) && (stateAfter == ESContentViewStateHidden))
	{
		// close
		[self.expandedViewController hide];
		[self.bannerViewDelegate didLeaveModalMode];
		[self.expandedBannerViewDelegate didHide];
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

#pragma mark -- Private methods
- (void)showWithController
{
	self.expandedViewController = [[[ESExpandedContentBannerViewController alloc] initAndShowWithBannerView:self
																						  parentController:self.rootViewController
																									  size:CGSizeMake(self.expandProperties.width, self.expandProperties.height)
																						 customCloseButton:self.expandProperties.useCustomClose] autorelease];
	[self.bannerViewDelegate willEnterModalMode];
}

@end

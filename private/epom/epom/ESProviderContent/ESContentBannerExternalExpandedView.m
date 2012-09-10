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
@property (readwrite, retain) ESExpandedContentBannerViewController *expandedViewController;

@end

@implementation ESContentBannerExternalExpandedView

@synthesize bannerViewDelegate = delegate_;
@synthesize expandedBannerViewDelegate = expandedDelegate_;
@synthesize expandedViewController = expandedViewController_;

- (id)initWithExpandProperties:(struct ESContentBannerViewExpandProperties)expandProperties
					   content:(NSString *)content
		   modalViewController:(UIViewController *)controller
				  viewDelegate:(id<ESContentBannerViewDelegate>)delegate
		  expandedViewDelegate:(id<ESContentBannerExternalExpandedViewDelegate>) expandedViewDelegate
{
	self = [super initWithFrame:CGRectMake(0, 0, expandProperties.width, expandProperties.width) modalViewController:controller expandProperties:&expandProperties];
	[super setDerived:self];
	
	if (self == nil)
	{
		return nil;
	}
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

- (void)onAdHasBeenTapped
{
}

- (void)onAdWillEnterModalMode
{
}

- (void)onAdDidLeaveModalMode
{
}

- (void)onAdWillLeaveApp
{
	[self.bannerViewDelegate willLeaveApplication];
}

- (CLLocation *)onGeoLocationRequest
{
	return [self.bannerViewDelegate geoLocation];
}

- (BOOL)onExpand:(NSString *)url
{
	return YES;
}

- (void)onBeforeStateChangeFrom:(enum ESContentBannerViewState)stateBefore to:(enum ESContentBannerViewState)stateAfter
{	
}

- (void)onAfterStateChangeFrom:(enum ESContentBannerViewState)stateBefore to:(enum ESContentBannerViewState)stateAfter
{
	if ((stateBefore == ESContentBannerViewStateExpanded) && (stateAfter == ESContentBannerViewStateDefault))
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

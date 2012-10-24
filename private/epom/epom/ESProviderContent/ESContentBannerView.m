//
//  ESContentBannerView.m
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import "ESContentBannerView.h"
#import "ESContentBannerExternalExpandedView.h"

#import "EpomSettings.h"

static const int kActivityIndicatorTag = 'itag';

@interface ESContentBannerView ()

// external expanded banner data for two-part ads
@property (readwrite, retain) ESDownloader *externalBannerDownloader;

// external expanded banner
@property (readwrite, retain) ESContentBannerExternalExpandedView *externalBannerView;

// view controller for expanded ad
@property (readwrite, retain) ESExpandedContentBannerViewController *expandedViewController;

// root view controller
@property (readwrite, assign) UIViewController *modalViewController;

@end

@implementation ESContentBannerView

@synthesize bannerViewDelegate = delegate_;

@synthesize expandedViewController = expandedViewController_;
@synthesize modalViewController = modalViewController_;
@synthesize externalBannerDownloader = externalBannerDownloader_;
@synthesize externalBannerView = externalBannerView_;

- (id)initWithFrame:(CGRect)frame modalViewController:(UIViewController *)controller
{
	
	self = [super initWithFrame:frame expandProperties:nil isInterstitial:NO autoShow:YES];
	[super setDerived:self];
	
	if (self == nil)
	{
		return nil;
	}
	
	self.modalViewController = controller;
	
	return self;
}

- (void)dealloc
{
	[self.expandedViewController hide];
	self.expandedViewController = nil;
	if (self.externalBannerView)
	{
		self.externalBannerView.bannerViewDelegate = nil;
		self.externalBannerView.expandedBannerViewDelegate = nil;
		self.externalBannerView = nil;
	}
	
	if (self.externalBannerDownloader != nil)
	{
		self.externalBannerDownloader.delegate = nil;
		self.externalBannerDownloader = nil;		
	}
	
	[super setDerived:nil];
	[super dealloc];
}

#pragma mark -- ESDownloaderDelegate implementation

-(void) downloaderDidFinishedDownload:(ESDownloader *)downloader
{
	ASSERT(downloader == self.externalBannerDownloader);
	
	[self loadExternalExpandedBannerWithContent: self.externalBannerDownloader.data];
}

-(void) downloader:(ESDownloader *)downloader didFailWithError:(NSError *)error
{
	ASSERT(downloader == self.externalBannerDownloader);

	[self hideActivityIndicator];
	
	// do nothing
}

#pragma mark -- ESContentBannerViewBaseDerivedProtocol implementation

- (void)onAdLoadError:(NSError *)error
{
	[self.bannerViewDelegate didFailToRecieveAdWithError:error];
}

- (void)onAdLoadSuccess
{
	[self.bannerViewDelegate didRecieveAd];
}

- (void)onAdWillEnterModalMode
{
	[self.bannerViewDelegate willEnterModalMode];
}

- (void)onAdDidLeaveModalMode
{
	[self.bannerViewDelegate didLeaveModalMode];
}

- (void)onUserInteractionWithWillLeaveApp:(BOOL)willLeaveApp
{
	[self.bannerViewDelegate hasBeenTapped];
	if (willLeaveApp)
	{
		[self.bannerViewDelegate willLeaveApplication];
	}
}

- (BOOL)onExpand:(NSString *)url
{
	if (url == nil)
	{
		return YES;
	}
	
	// add activity indicator
	{
		UIActivityIndicatorView *view = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
		view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
		view.tag = kActivityIndicatorTag;
		[view startAnimating];
		[self addSubview:view];
	}

	if (self.externalBannerDownloader != nil && self.externalBannerDownloader.state == ESDownloaderStateDone) // load external html data
	{
		[self loadExternalExpandedBannerWithContent:self.externalBannerDownloader.data];
	}
	else
	{
		// start downloading
		self.externalBannerDownloader = [[[ESDownloader alloc] initWithURL:[NSURL URLWithString:url] delegate:self] autorelease];
	}
	return NO;
}

- (void)onBeforeStateChangeFrom:(ESContentViewState)stateBefore to:(ESContentViewState)stateAfter
{
}

- (void)onAfterStateChangeFrom:(ESContentViewState)stateBefore to:(ESContentViewState)stateAfter
{
	if ((stateBefore == ESContentViewStateExpanded) && (stateAfter == ESContentViewStateDefault))
	{
		[self.expandedViewController hide];
		self.expandedViewController = nil;
		
		[self.bannerViewDelegate didLeaveModalMode];
	}
	
	if ((stateBefore == ESContentViewStateDefault) && (stateAfter == ESContentViewStateExpanded))
	{
		self.expandedViewController = [[[ESExpandedContentBannerViewController alloc] initAndShowWithBannerView:self
																							   parentController:self.modalViewController
																										   size:CGSizeMake(expandProperties_.width, expandProperties_.height)
																							  customCloseButton:expandProperties_.useCustomClose] autorelease];
		[self.bannerViewDelegate willEnterModalMode];
	}	
}

- (UIViewController *)onControllerForEmbeddedBrowserRequest
{
	return self.viewState == ESContentViewStateDefault ? self.modalViewController : self.expandedViewController;
}

- (BOOL)treatExpandAsUserInteraction
{
	return YES;
}

#pragma mark -- ESContentBannerExternalExpandedViewDelegate protocol

- (void)didFinishLoading
{
	[self hideActivityIndicator];
	[self simulateMRAIDExpanding];
}

- (void)didFailLoadingWithError:(NSError *)error
{
	[self hideActivityIndicator];
	
	self.externalBannerView.delegate = nil;
	self.externalBannerView = nil;
}

- (void)didHide
{
	[self simulateMRAIDShrinking];
	self.externalBannerView.delegate = nil;
	self.externalBannerView = nil;
}


#pragma mark -- Private methods

- (void)loadExternalExpandedBannerWithContent:(NSData *)data
{
	NSString *content = [[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding] autorelease];
	
	self.externalBannerView = [[[ESContentBannerExternalExpandedView alloc] initWithExpandProperties:self.expandProperties
																							 content:content
																				 modalViewController:self.modalViewController
																						viewDelegate:self.bannerViewDelegate
																				expandedViewDelegate:self] autorelease];
}

- (void)hideActivityIndicator
{
	// remove activity view
	{
		UIView *view = [self viewWithTag:kActivityIndicatorTag];
		[view removeFromSuperview];
	}
}
@end

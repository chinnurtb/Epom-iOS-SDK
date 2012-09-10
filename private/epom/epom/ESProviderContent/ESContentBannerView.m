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

@end

@implementation ESContentBannerView

@synthesize bannerViewDelegate = delegate_;

@synthesize expandedViewController = expandedViewController_;

@synthesize externalBannerDownloader = externalBannerDownloader_;
@synthesize externalBannerView = externalBannerView_;

- (id)initWithFrame:(CGRect)frame modalViewController:(UIViewController *)controller
{
	
	self = [super initWithFrame:frame modalViewController:controller expandProperties:nil];
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
	assert(downloader == self.externalBannerDownloader);
	
	[self loadExternalExpandedBannerWithContent: self.externalBannerDownloader.data];
}

-(void) downloader:(ESDownloader *)downloader didFailWithError:(NSError *)error
{
	assert(downloader == self.externalBannerDownloader);

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

- (void)onAdHasBeenTapped
{
	[self.bannerViewDelegate hasBeenTapped];
}

- (void)onAdWillEnterModalMode
{
	[self.bannerViewDelegate willEnterModalMode];
}

- (void)onAdDidLeaveModalMode
{
	[self.bannerViewDelegate didLeaveModalMode];
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

- (void)onBeforeStateChangeFrom:(enum ESContentBannerViewState)stateBefore to:(enum ESContentBannerViewState)stateAfter
{
	switch (stateAfter)
	{
		case ESContentBannerViewStateDefault:
			switch (stateBefore)
			{
			case ESContentBannerViewStateExpanded:
				[self.expandedViewController hide];
				self.expandedViewController = nil;
				
				[self.bannerViewDelegate didLeaveModalMode];
				break;
			default:
				break;
			}
			break;
		case ESContentBannerViewStateExpanded:
			// still is displayed
			self.expandedViewController = [[[ESExpandedContentBannerViewController alloc] initAndShowWithBannerView:self
																								   parentController:self.rootViewController
																											   size:CGSizeMake(expandProperties_.width, expandProperties_.height)
																								  customCloseButton:expandProperties_.useCustomClose] autorelease];
			[self.bannerViewDelegate willEnterModalMode];
			break;
		default:
			break;
	}

}

- (void)onAfterStateChangeFrom:(enum ESContentBannerViewState)stateBefore to:(enum ESContentBannerViewState)stateAfter
{
	
}

- (UIViewController *)onControllerForEmbeddedBrowserRequest
{
	return self.state == ESContentBannerViewStateDefault ? self.rootViewController : self.expandedViewController;
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
																				 modalViewController:self.rootViewController
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

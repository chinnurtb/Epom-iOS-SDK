//
//  ViewController.m
//  test_ipad
//
//  Created by Epom LTD on 5/28/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ViewController.h"

#import "epom/ESBannerView.h"
#import "epom/ESInterstitialView.h"
#import "epom/ESUtils.h"

static const int kActivityIndicatorTag = 'tact';

@implementation ViewController

@synthesize esBannerView;
@synthesize esInterstitialView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[ESUtils setLogLevel:ESVerboseAll];
	
	self.esBannerView = [[ESBannerView alloc] initWithID:EPOM_BANNER_KEY
											  sizeType:ESBannerViewSize768x90
								   modalViewController:self
										   useLocation:YES
											  testMode:YES];

	self.esBannerView.delegate = self;
	self.esBannerView.refreshTimeInterval = 40.0;
		
	[self.view addSubview:self.esBannerView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -- ESBannerViewDelegate protocol implementation

-(void)esBannerViewWillEnterModalMode:(ESBannerView *)esBannerView
{
	NSLog(@"ESBannerView will enter modal mode");
}

-(void)esBannerViewDidLeaveModalMode:(ESBannerView *)esBannerView
{
	NSLog(@"ESBannerView did leave modal mode");
}

-(void)esBannerViewWillLeaveApplication:(ESBannerView *)esBannerView
{
	NSLog(@"ESBannerView will leave application");
}

#pragma mark -- ESInterstitialView support

-(IBAction)showInterstitialAd:(id)sender
{
	self.esInterstitialView = [[[ESInterstitialView alloc] initWithID:EPOM_INTERSTITIAL_KEY
														  useLocation:YES
															 testMode:YES] autorelease];
	self.esInterstitialView.delegate = self;
}

-(void)showInterstitialActivityIndicator
{
	UIActivityIndicatorView *view = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	view.center = CGPointMake(CGRectGetMidX(btnShowInterstitial.bounds), CGRectGetMidY(btnShowInterstitial.bounds));
	view.tag = kActivityIndicatorTag;
	[view startAnimating];
	[btnShowInterstitial addSubview:view];
	btnShowInterstitial.enabled = NO;
}

-(void)hideInterstitialActivityIndicator
{
	UIView *view = [btnShowInterstitial viewWithTag:kActivityIndicatorTag];
	[view removeFromSuperview];
	btnShowInterstitial.enabled = YES;
}

#pragma mark -- ESInterstitialView delegate implementation

-(void)esInterstitialViewDidStartLoadAd:(ESInterstitialView *)esInterstitial
{
	[self showInterstitialActivityIndicator];
	NSLog(@"ESInterstitialView did start loading ad");
}

-(void)esInterstitialViewDidFailLoadAd:(ESInterstitialView *)esInterstitial
{
	[self hideInterstitialActivityIndicator];
	
	assert(esInterstitial == self.esInterstitialView);
	self.esInterstitialView.delegate = nil;
	self.esInterstitialView = nil;
	
	NSLog(@"ESInterstitialView did fail to load ad");
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
													 message:@"Failed to load interstitial ad. See console log output."
													delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil, nil] autorelease];
	[alert show];
}

-(void)esInterstitialViewDidLoadAd:(ESInterstitialView *)esInterstitial
{
	NSLog(@"ESInterstitialView loaded ad successfully");
	
	assert(esInterstitial == self.esInterstitialView);
	[self.esInterstitialView presentWithViewController:self];
	
}

-(void)esInterstitialViewWillEnterModalMode:(ESInterstitialView *)esInterstitial
{
	NSLog(@"ESInterstitialView will enter modal mode");
}

-(void)esInterstitialViewDidLeaveModalMode:(ESInterstitialView *)esInterstitial
{
	NSLog(@"ESInterstitialView did leave modal mode");
	
	[self hideInterstitialActivityIndicator];
}

-(void)esInterstitialViewUserInteraction:(ESInterstitialView *)esInterstitialView willLeaveApplication:(BOOL)yesOrNo;
{
	NSLog(@"ESInterstitialView user interaction");
}


@end

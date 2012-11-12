//
//  ViewController.m
//  test_iphone
//
//  Created by Epom LTD on 5/28/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ViewController.h"

#import "epom/ESBannerView.h"
#import "epom/ESInterstitialView.h"
#import "epom/ESUtils.h"

#define TOGGLE_PLACEMENT_TIMER 20.0
static const int kActivityIndicatorTag = 'tact';

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[ESUtils setLogLevel:ESVerboseAll];
	
	ESBannerView *esBannerView = [[[ESBannerView alloc] initWithID:@"53927211d9604e5d671963fd013dd94b"
												 sizeType:ESBannerViewSize320x50
									  modalViewController:self
											  useLocation:NO
												 testMode:YES] autorelease];

	esBannerView.delegate = self;
	esBannerView.refreshTimeInterval = 10.0;
	[self.view addSubview:esBannerView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;	
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
	return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark -- ESBannerViewDelegate protocol implementation

-(void)esBannerViewWillShowAd:(ESBannerView *)esBannerView
{
	NSLog(@"ESBannerView will show ad");
}

-(void)esBannerViewDidShowAd:(ESBannerView *)esBannerView
{
	NSLog(@"ESBannerView did show ad");
}

-(void)esBannerViewAdHasBeenTapped:(ESBannerView *)esBannerView
{
	NSLog(@"ESBannerView ad has been tapped");
}

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
	ESInterstitialView *esInterstitialView = [[ESInterstitialView alloc] initWithID:@"53927211d9604e5d671963fd013dd94b"
														  useLocation:YES
															 testMode:YES];
	esInterstitialView.delegate = self;
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
	
	[esInterstitial release];
	
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
	
	[esInterstitial presentWithViewController:self];
}

-(void)esInterstitialViewWillEnterModalMode:(ESInterstitialView *)esInterstitial
{
	NSLog(@"ESInterstitialView will enter modal mode");
}

-(void)esInterstitialViewDidLeaveModalMode:(ESInterstitialView *)esInterstitial
{
	NSLog(@"ESInterstitialView did leave modal mode");
	[esInterstitial release];
	
	[self hideInterstitialActivityIndicator];
}

-(void)esInterstitialViewUserInteraction:(ESInterstitialView *)esInterstitialView willLeaveApplication:(BOOL)yesOrNo;
{
	NSLog(@"ESInterstitialView user interaction");
}

@end

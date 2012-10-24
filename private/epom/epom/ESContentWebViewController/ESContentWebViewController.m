//
//  ESContentWebViewController.h
//  Epom SDK
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import "ESContentWebViewController.h"

@implementation ESContentWebViewController
@synthesize delegate;

- (void) loadBrowser: (NSURL *) url
{
	// Check for network connectivity
	if ([ESUtilsPrivate isNetworkReachable])
	{		
		webView.delegate = self;
		
		[webView loadRequest:[NSURLRequest requestWithURL:url]];						
	}
	else
	{
		[self showNoNetworkAlert];	
	}
}

- (IBAction) browseBack: (id) sender
{
	if ([webView canGoBack])
	{
		[webView goBack];
	}
	else
	{
		[self dismiss:NO];
	}
	
}

- (IBAction) browseForward: (id) sender
{
	[webView goForward];		
}

- (IBAction) stopOrReLoadWeb: (id) sender
{
	[webView reload];
}


- (IBAction) launchSafari: (id) sender
{	
	[self dismiss:YES];
	[[UIApplication sharedApplication] openURL:[[webView request] URL]];
}

- (void) dismiss:(BOOL)willLeaveApp
{
	UIViewController *parent = nil;
	if ([self respondsToSelector:@selector(presentingViewController)])
	{
		parent = [self presentingViewController];
	}
	else
	{
		parent = [self parentViewController];
	}
	
	[parent dismissModalViewControllerAnimated:YES];
	[delegate onDismissWebView:willLeaveApp];
}

- (void) showNoNetworkAlert
{
	UIAlertView *baseAlert = [[UIAlertView alloc] initWithTitle:@"No Network"
														message:@"A network connection is required.  Please verifiy your network settings and try again." 
													   delegate:nil cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];	
	[baseAlert show];
	[baseAlert release];
}

//
#pragma mark UIWebView delegate methods
//

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // starting the load, show the activity indicator in the status bar
	[busyWebIcon startAnimating];				
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView1
{
    // finished loading, hide the activity indicator
 	[busyWebIcon stopAnimating];	
	
	BOOL canGoForward = [webView canGoForward];
	
	webForward.enabled = canGoForward;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // load error, hide the activity indicator in the status bar
	[busyWebIcon stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	// Check for network connectivity
	if ([ESUtilsPrivate isNetworkReachable])
	{
		return YES;
	}
	else
	{
		[self showNoNetworkAlert];		
		return NO;
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // We support any orientation
    return (YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(IBAction)back: (id)sender
{
	//  If we go back past the first web page in the cache, then dismiss the web view
	
	if ([webView canGoBack])
	{
		[webView goBack];
	}
	else
	{	
		[self dismiss:NO];
	}
}

-(IBAction)done: (id)sender
{
	[self dismiss:NO];
}

- (void)dealloc
{
	self.delegate = nil;
	[super dealloc];
}

#pragma mark -- init controls

- (id) initWithControls
{
	self = [super initWithNibName:nil bundle:nil];
	if (self == nil)
	{
		return nil;
	}
	
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 460.0)];
	mainView.alpha = 1.000;
	mainView.autoresizesSubviews = YES;
	mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	mainView.backgroundColor = [UIColor colorWithRed:0.000 green:0.016 blue:0.024 alpha:1.000];
	mainView.clearsContextBeforeDrawing = YES;
	mainView.clipsToBounds = NO;
	mainView.contentMode = UIViewContentModeBottomLeft;
	mainView.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
	mainView.frame = CGRectMake(0.0, 0.0, 320.0, 460.0);
	mainView.hidden = NO;
	mainView.multipleTouchEnabled = NO;
	mainView.opaque = YES;
	mainView.tag = 0;
	mainView.userInteractionEnabled = YES;
		
	UIActivityIndicatorView *busyIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	busyIndicatorView.alpha = 1.000;
	busyIndicatorView.autoresizesSubviews = YES;
	busyIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	busyIndicatorView.clearsContextBeforeDrawing = NO;
	busyIndicatorView.clipsToBounds = NO;
	busyIndicatorView.contentMode = UIViewContentModeScaleToFill;
	busyIndicatorView.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");

	busyIndicatorView.hidesWhenStopped = YES;
	busyIndicatorView.multipleTouchEnabled = NO;
	busyIndicatorView.opaque = NO;
	busyIndicatorView.tag = 0;
	busyIndicatorView.userInteractionEnabled = NO;
	[busyIndicatorView stopAnimating];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 416.0, 320.0, 44.0)];
	toolbar.alpha = 1.000;
	toolbar.autoresizesSubviews = YES;
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	toolbar.barStyle = UIBarStyleBlackOpaque;
	toolbar.clearsContextBeforeDrawing = NO;
	toolbar.clipsToBounds = NO;
	toolbar.contentMode = UIViewContentModeScaleToFill;
	toolbar.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
	toolbar.hidden = NO;
	toolbar.multipleTouchEnabled = NO;
	toolbar.opaque = NO;
	toolbar.tag = 0;
	toolbar.userInteractionEnabled = YES;
	
	
	UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 416.0)];
	webview.alpha = 1.000;
	webview.autoresizesSubviews = YES;
	webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	webview.backgroundColor = [UIColor colorWithWhite:1.000 alpha:1.000];
	webview.clearsContextBeforeDrawing = YES;
	webview.clipsToBounds = YES;
	webview.contentMode = UIViewContentModeBottomLeft;
	webview.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
	webview.hidden = NO;
	webview.multipleTouchEnabled = YES;
	webview.opaque = YES;
	webview.scalesPageToFit = YES;
	webview.tag = 0;
	webview.userInteractionEnabled = YES;
	
	
	UIFont *arrowsFont = [UIFont systemFontOfSize:32];
	unichar backArrowCode = 0x2190; //BLACK RIGHT-POINTING TRIANGLE		
	unichar forwardArrowCode = 0x2192; //BLACK LEFT-POINTING TRIANGLE	
	
	UIButton *backArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backArrowButton setTitle:[NSString stringWithCharacters:&backArrowCode length:1] forState:UIControlStateNormal];
	[backArrowButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
	[backArrowButton setShowsTouchWhenHighlighted:YES];
	backArrowButton.titleLabel.font = arrowsFont;
	CGSize backSize = [backArrowButton.titleLabel.text sizeWithFont:backArrowButton.titleLabel.font]; 
	[backArrowButton setFrame:CGRectMake(0, 0, backSize.width, backSize.height)];
	[backArrowButton addTarget:self action:@selector(browseBack:) forControlEvents:UIControlEventTouchUpInside];

	UIButton *forwardArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[forwardArrowButton setTitle:[NSString stringWithCharacters:&forwardArrowCode length:1] forState:UIControlStateNormal];
	[forwardArrowButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
	[forwardArrowButton setShowsTouchWhenHighlighted:YES];
	forwardArrowButton.titleLabel.font = arrowsFont;	
	CGSize forwardSize = [forwardArrowButton.titleLabel.text sizeWithFont:forwardArrowButton.titleLabel.font]; 
	[forwardArrowButton setFrame:CGRectMake(0, 0, forwardSize.width, forwardSize.height)];
	[forwardArrowButton addTarget:self action:@selector(browseForward:) forControlEvents:UIControlEventTouchUpInside];
	
	
	UIBarButtonItem *buttonBack = [[UIBarButtonItem alloc] initWithCustomView:backArrowButton];
	UIBarButtonItem *buttonForward = [[UIBarButtonItem alloc] initWithCustomView:forwardArrowButton];				
	UIBarButtonItem *flexSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];		
	UIBarButtonItem *buttonRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(stopOrReLoadWeb:)];
	UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *buttonSystemHandle = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(launchSafari:)];
	UIBarButtonItem *flexSpace3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	
	NSMutableArray *items = [[[NSMutableArray alloc] init] autorelease];
	[items addObject:[buttonBack autorelease]];	
	[items addObject:[buttonForward autorelease]];
	[items addObject:[flexSpace1 autorelease]];
	[items addObject:[buttonRefresh autorelease]];
	[items addObject:[flexSpace2 autorelease]];
	[items addObject:[buttonSystemHandle autorelease]];
	[items addObject:[flexSpace3 autorelease]];
	[items addObject:[buttonDone autorelease]];
	
	toolbar.items = items;

	self.view = [mainView autorelease];

	[mainView addSubview:[toolbar autorelease]];
	[mainView addSubview:[webview autorelease]];
	[webview addSubview:[busyIndicatorView autorelease]];
	busyIndicatorView.center = CGPointMake(CGRectGetMidX(webview.bounds), CGRectGetMidY(webview.bounds));
			
	// assign outlets
	self->webView = webview;
	self->busyWebIcon = busyIndicatorView;
	self->webForward = buttonForward;	
	self->toolBar = toolbar;

	
	return self;
}

@end

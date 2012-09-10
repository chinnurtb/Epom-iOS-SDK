//
//  ViewController.m
//  test_iphone
//
//  Created by Epom LTD on 5/28/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ViewController.h"

#import "epom/ESView.h"

#define TOGGLE_PLACEMENT_TIMER 20.0

@implementation ViewController

@synthesize esView;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[self rearrange:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.esView = nil;
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
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -- ESViewDelegate protocol implementation

-(void)esViewWillShowAd:(ESView *)esView
{
	NSLog(@"ESView will show ad");
}

-(void)esViewDidShowAd:(ESView *)esView
{
	NSLog(@"ESView did show ad");
}

-(void)esViewAdHasBeenTapped:(ESView *)esView
{
	NSLog(@"ESView ad has been tapped");
}

-(void)esViewWillEnterModalMode:(ESView *)esView
{
	NSLog(@"ESView will enter modal mode");
}

-(void)esViewDidLeaveModalMode:(ESView *)esView
{
	NSLog(@"ESView did leave modal mode");
}

-(void)esViewWillLeaveApplication:(ESView *)esView
{
	NSLog(@"ESView will leave application");
}

-(void)rearrange:(id)sender
{
	[self.esView removeFromSuperview];
	self.esView = nil;
	
	self.esView = [ESView viewWithID:@"53927211d9604e5d671963fd013dd94b"
							sizeType:ESViewSize320x50
				 modalViewController:self
						 useLocation:YES
							testMode:YES
						verboseLevel:ESVerboseAll];
	
	self.esView.delegate = self;
	self.esView.refreshTimeInterval = 10.0;
	static int cnt = 0;
	CGRect frame = self.esView.frame;
	frame.origin.y = ((cnt++) % 2) ? 410 : 0;
	self.esView.frame = frame;
	
	[self.view addSubview:self.esView];
	
	//[self performSelector:@selector(rearrange:) withObject:self afterDelay:TOGGLE_PLACEMENT_TIMER];
}

@end

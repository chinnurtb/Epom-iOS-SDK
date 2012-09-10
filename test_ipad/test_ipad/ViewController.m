//
//  ViewController.m
//  test_ipad
//
//  Created by Epom LTD on 5/28/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ViewController.h"

#import "epom/ESView.h"

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
	
	BOOL testMode = YES;//NSOrderedSame == [[[UIDevice currentDevice] model] compare:@"iPad Simulator"];
	
	self.esView = [ESView viewWithID:@"53927211d9604e5d671963fd013dd94b" 
							sizeType:ESViewSize768x90 
				 modalViewController:self				   
						 useLocation:YES 
							testMode:testMode
						verboseLevel:ESVerboseAll];	

	self.esView.delegate = self;
	self.esView.refreshTimeInterval = 4.0;
		
	[self.view addSubview:self.esView];
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
    // Return YES for supported orientations
	return YES;
}

#pragma mark -- ESViewDelegate protocol implementation

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


@end

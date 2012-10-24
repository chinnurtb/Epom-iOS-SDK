//
//  ESPortraitViewController.m
//  Epom SDK
//
//  Created by Epom LTD on 10/23/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESPortraitViewController.h"

@implementation ESPortraitViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
			(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end

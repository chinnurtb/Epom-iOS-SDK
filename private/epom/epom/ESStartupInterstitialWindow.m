//
//  ESStartupInterstitialWindow.m
//  Epom SDK
//
//  Created by Epom LTD on 10/23/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESStartupInterstitialWindow.h"

#import "Utilities/ESPortraitViewController.h"

@interface ESStartupInterstitialWindow()

@property (readwrite, retain) UIWindow *storedWindow;
@property (readwrite, assign) BOOL statusBarWasVisible;
@end

@implementation ESStartupInterstitialWindow

@synthesize storedWindow;
@synthesize statusBarWasVisible;

-(id)initAndPresentWithReplacedWindow:(UIWindow *)windowToReplace image:(UIImage *)image;
{
	self = [super initWithFrame:windowToReplace.frame];
	
	if (self == nil)
	{
		return nil;
	}
	UIImageView *view = [[[UIImageView alloc] initWithImage:image] autorelease];
	
	self.rootViewController = [[[ESPortraitViewController alloc] init] autorelease];
	self.rootViewController.wantsFullScreenLayout = YES;
	self.rootViewController.view = view;
	
	self.storedWindow = windowToReplace;
	
	// switch windows
	[self makeKeyAndVisible];
	
	self.storedWindow.hidden = YES;
	
	self.statusBarWasVisible = [UIApplication sharedApplication].statusBarHidden == NO;

	if (self.statusBarWasVisible)
	{
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	}
	
	return self;
}

-(void)dealloc
{
	[self dismiss];
	self.storedWindow = nil;
	self.rootViewController = nil;
	
	[super dealloc];
}

-(void)dismiss
{
	if (self.hidden == NO)
	{
		//switch windows
		[self.storedWindow makeKeyAndVisible];

		if (self.statusBarWasVisible)
		{
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
		}
		
		self.hidden = YES;
		self.rootViewController = nil;		
	}
}

@end

//
//  ESExpandedContentBannerViewController.m
//  Epom SDK
//
//  Created by Epom LTD on 9/3/12.
//
//

#import "ESExpandedContentBannerViewController.h"

#import "ESContentViewBase.h"

#import "EpomSettings.h"

#import "expanded_ad_close_normal_png.h"
#import "expanded_ad_close_normal@2x_png.h"
#import "expanded_ad_close_pressed_png.h"
#import "expanded_ad_close_pressed@2x_png.h"

@interface ESExpandedContentBannerViewController ()

@property (readwrite, assign) UIView *originalParent;
@property (readwrite, assign) ESContentViewBase *bannerView;

@end

@implementation ESExpandedContentBannerViewController

@synthesize originalParent = originalParent_;
@synthesize bannerView = bannerView_;

- (id)initAndShowWithBannerView:(ESContentViewBase *)view
			   parentController:(UIViewController *)controller
						   size:(CGSize)size
			  customCloseButton:(BOOL)customCloseButton
{
	self = [super init];
	if (self == nil)
	{
		return nil;
	}
	
	self.bannerView = view;
	self.originalParent = [self.bannerView superview];
	originalRect_ = [self.bannerView frame];
		
	[controller presentModalViewController:self animated:NO];	
			
	[self.view addSubview:self.bannerView];
	[self.view bringSubviewToFront:self.bannerView];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	self.bannerView.frame = CGRectMake((screenRect.size.width - size.width) / 2,
								(screenRect.size.height - size.height) / 2,
								size.width, size.height);
	if (customCloseButton == NO)
	{
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 36, 36);
		
		UIImage *closeNormal = nil, *closePressed = nil;
		
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && ([[UIScreen mainScreen] scale] > 1.0))
		{
			// retina display
			closeNormal = [UIImage imageWithData:[NSData dataWithBytesNoCopy:expanded_ad_close_normal_2x_png
																	  length:ARRAY_SIZE(expanded_ad_close_normal_2x_png)
																freeWhenDone:NO]];
			closePressed = [UIImage imageWithData:[NSData dataWithBytesNoCopy:expanded_ad_close_pressed_2x_png
																	   length:ARRAY_SIZE(expanded_ad_close_pressed_2x_png)
																 freeWhenDone:NO]];
		}
		else
		{
			closeNormal = [UIImage imageWithData:[NSData dataWithBytesNoCopy:expanded_ad_close_normal_png
																	  length:ARRAY_SIZE(expanded_ad_close_normal_png)
																freeWhenDone:NO]];
			closePressed = [UIImage imageWithData:[NSData dataWithBytesNoCopy:expanded_ad_close_pressed_png
																	  length:ARRAY_SIZE(expanded_ad_close_pressed_png)
																freeWhenDone:NO]];
		}
		
		[closeButton setImage:closeNormal forState:UIControlStateNormal];
		[closeButton setImage:closePressed forState:UIControlStateHighlighted];
		
		[closeButton addTarget:self action:@selector(onBtnClosePress) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:closeButton];
	}
	
	return self;
}

- (void)dealloc
{
	self.bannerView = nil;
	self.originalParent = nil;

	[super dealloc];
}

- (id)retain
{
	return [super retain];
}

- (oneway void)release
{
	[super release];
}

- (void)hide
{
	[self dismissModalViewControllerAnimated:NO];
	
	// make animation
	if (self.bannerView)
	{
		[self.bannerView removeFromSuperview];
		[self.originalParent addSubview:self.bannerView];
		
		self.bannerView.frame = originalRect_;
	}	
	
	self.bannerView = nil;
	self.originalParent = nil;
}

- (void)onBtnClosePress
{
	[self.bannerView close];
}

@end

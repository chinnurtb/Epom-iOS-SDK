//
//  ESExpandedContentBannerViewController.h
//  Epom SDK
//
//  Created by Epom LTD on 9/3/12.
//
//

#import "ESPortraitViewController.h"

@class ESContentViewBase;

@interface ESExpandedContentBannerViewController : ESPortraitViewController
{
	UIView *originalParent_;
	ESContentViewBase *bannerView_;
	CGRect originalRect_;
}

- (id)initAndShowWithBannerView:(ESContentViewBase *)view
			   parentController:(UIViewController *)controller
						   size:(CGSize)size
			  customCloseButton:(BOOL)yesOrNo;
- (void)hide;

@end

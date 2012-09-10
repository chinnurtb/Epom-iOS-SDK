//
//  ESExpandedContentBannerViewController.h
//  Epom SDK
//
//  Created by Epom LTD on 9/3/12.
//
//

#import <UIKit/UIKit.h>

@class ESContentBannerViewBase;

@interface ESExpandedContentBannerViewController : UIViewController
{
	UIView *originalParent_;
	ESContentBannerViewBase *bannerView_;
	CGRect originalRect_;
}

- (id)initAndShowWithBannerView:(ESContentBannerViewBase *)view
			   parentController:(UIViewController *)controller
						   size:(CGSize)size
			  customCloseButton:(BOOL)yesOrNo;
- (void)hide;

@end

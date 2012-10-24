//
//  ESContentBannerExternalExpandedView.h
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import "ESContentViewBase.h"

#import "ESContentBannerViewDelegate.h"
#import "ESContentBannerExternalExpandedViewDelegate.h"


#import "ESExpandedContentBannerViewController.h"

@protocol ESContentBannerViewDelegate;

@interface ESContentBannerExternalExpandedView : ESContentViewBase<ESContentViewBaseDerivedProtocol>
{
	// view controller for expanded ad
	ESExpandedContentBannerViewController *expandedViewController_;
	
	// root view controller
	UIViewController *rootViewController_;
	
	// delegate
	id<ESContentBannerViewDelegate> delegate_;
	id<ESContentBannerExternalExpandedViewDelegate> expandedDelegate_;
}

@property (readwrite, assign) id<ESContentBannerViewDelegate> bannerViewDelegate;
@property (readwrite, assign) id<ESContentBannerExternalExpandedViewDelegate> expandedBannerViewDelegate;

- (id)initWithExpandProperties:(ESContentViewExpandProperties)expandProperties
					   content:(NSString *)content
		   modalViewController:(UIViewController *)controller
				  viewDelegate:(id<ESContentBannerViewDelegate>)delegate
		  expandedViewDelegate:(id<ESContentBannerExternalExpandedViewDelegate>) expandedViewDelegate;

@end


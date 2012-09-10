//
//  ESContentBannerExternalExpandedViewDelegate.h
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

@protocol ESContentBannerExternalExpandedViewDelegate

@optional

- (void)didFinishLoading;
- (void)didFailLoadingWithError:(NSError *)error;

- (void)didHide;

@end

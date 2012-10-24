//
//  ESContentBannerViewDelegate.h
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

@protocol ESContentBannerViewDelegate

@optional

- (void)didRecieveAd;
- (void)didFailToRecieveAdWithError:(NSError *)error;

- (void)willEnterModalMode;
- (void)didLeaveModalMode;
- (void)willLeaveApplication;
- (void)hasBeenTapped;

@end

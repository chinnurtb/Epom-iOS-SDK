//
//  ESContentInterstitialViewDelegate.h
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

@protocol ESContentInterstitialViewDelegate

@optional

- (void)didRecieveAd;
- (void)didFailToRecieveAdWithError:(NSError *)error;

- (void)willEnterModalMode;
- (void)didLeaveModalMode;
- (void)didPerformUserInteraction:(BOOL)willLeaveApplication;

@end

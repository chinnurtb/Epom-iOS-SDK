//
//  ESViewInner.h
//  Epom SDK
//
//  Created by Epom LTD on 6/8/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "epom/ESView.h"

#import "ESProviderDelegateProtocol.h"

#import "CoreLocation/CoreLocation.h"

@class ESViewInnerTimerWrapper;

@interface ESViewInner : ESView<NSURLConnectionDelegate, CLLocationManagerDelegate, ESProviderDelegate>
{
	NSString *apiKey;
	NSURLConnection *requestConnection;
	NSURLConnection *impressionConnection;
	NSURLConnection *clickConnection;
	NSMutableData *recievedData;
	
	NSMutableSet *bannedBannerIDs;
	NSMutableDictionary *tempBannedBannerIDs;
	
	ESProvider *currentProvider;
	ESProvider *desiredProvider;
	ESViewInnerTimerWrapper *timerWrapper;
	
	UIViewController *modalViewController;
	
	CLLocationManager *locator;
	CLLocation *latestLocation;
	
	ESViewSizeType sizeType;
	BOOL useLocation;
	BOOL testMode;
	
	BOOL updateEnabled;
	double adRequestCountDown;
}

+ (UInt32) numAliveViews;

- (id)initWithID:(NSString*)ID sizeType:(ESViewSizeType)size modalViewController:(UIViewController *)controller 
	 useLocation:(BOOL)doUseLocation testMode:(BOOL)inTestMode;

- (void)onUpdate;
@end

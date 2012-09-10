//
//  ESView.h
//  Epom SDK
//
//  Created by Epom LTD on 5/29/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	EpomSDK View class (ESView)

#import <UIKit/UIView.h>

#import "ESEnumerations.h"
#import "ESViewDelegateProtocol.h"

@class ESProvider;
@class UIViewController;

@interface ESView : UIView
{
	@private id<ESViewDelegate> delegate;	
	@private NSTimeInterval refreshTimeInterval;
}

// delegate accessor
@property (readwrite, assign) id<ESViewDelegate> delegate;

// refresh time interval accessor. Default value is 15 seconds. Minimal - 5 seconds
@property (readwrite, assign) NSTimeInterval refreshTimeInterval;

+(id)viewWithID:(NSString*)ID sizeType:(ESViewSizeType)size modalViewController:(UIViewController *)modalViewController 
	useLocation:(BOOL)doUseLocation testMode:(BOOL)testMode verboseLevel:(ESVerboseType)verboseType;

@end

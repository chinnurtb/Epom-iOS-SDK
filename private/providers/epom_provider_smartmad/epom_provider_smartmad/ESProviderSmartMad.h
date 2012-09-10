//
//  ESProviderSmartMad.h
//  ESProviderSmartMad
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProvider.h"

#import "SmartMad/SmartMadAdView.h"
#import "SmartMad/SmartMadDelegate.h"

@interface ESProviderSmartMad : ESProvider<SmartMadAdViewDelegate, SmartMadAdEventDelegate>
{
	SmartMadAdView *adView_;
	NSString *positionId_;
	
	AdMeasureType adMeasure_;
	AdCompileMode adCompileMode_;
}

@end

//
//  ESProviderSmartMad.h
//  ESProviderSmartMad
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderBanner.h"

#import "SmartMad/SmartMadAdView.h"
#import "SmartMad/SmartMadDelegate.h"

@interface ESProviderBannerSmartMad : ESProviderBanner<SmartMadAdViewDelegate, SmartMadAdEventDelegate>
{
	SmartMadAdView *adView_;
	NSString *positionId_;
	
	AdMeasureType adMeasure_;
	AdCompileMode adCompileMode_;
}

@end

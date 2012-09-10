//
//  ESProviderTapIt.h
//  ESProviderTapIt
//
//  Created by Epom LTD on 7/2/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//


#import <ESProvider.h>

#import "TapIt_iPhone_SDK/SDK/TapItHeaders/TapItAdMobile.h"

@interface ESProviderTapIt : ESProvider<TapItAdMobileViewDelegate>
{
	TapItAdMobileView *tapItView;
}

@property (readwrite, retain) TapItAdMobileView *tapItView;

@end

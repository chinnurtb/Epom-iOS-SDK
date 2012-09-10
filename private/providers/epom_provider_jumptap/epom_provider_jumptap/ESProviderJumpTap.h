//
//  ESProviderJumpTap.h
//  ESProviderJumpTap
//
//  Created by Epom LTD on 6/5/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESProvider.h"

#import "JTIPHONE/JTAdWidget.h"

@interface ESProviderJumpTap : ESProvider<JTAdWidgetDelegate>
{
	JTAdWidget *jtView;	
	
	NSString *publisherID;
	NSString *spotID;
	NSString *siteID;
}

@property (readwrite, retain) JTAdWidget *jtView;
@property (readwrite, retain) NSString *publisherID;
@property (readwrite, retain) NSString *spotID;
@property (readwrite, retain) NSString *siteID;

@end

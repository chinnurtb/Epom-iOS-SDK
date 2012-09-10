//
//  ESProviderManager.h
//  Epom SDK
//
//  Created by Epom LTD on 6/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESProviderManager : NSObject
{
	NSMutableDictionary *availableProviders;
	
	NSString *safariUserAgent;
}

@property (readonly) NSString *safariUserAgent;

+(ESProviderManager*)shared;

-(Class)providerClassForID:(NSString *)providerID;

@end
//
//  ESStartupInterstitialWindow.h
//  Epom SDK
//
//  Created by Epom LTD on 10/23/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESStartupInterstitialWindow : UIWindow

-(id)initAndPresentWithReplacedWindow:(UIWindow *)windowToReplace image:(UIImage *)image;

-(void)dismiss;

@end

//
//  ViewController.h
//  test_ipad
//
//  Created by Epom LTD on 5/28/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "epom/ESViewDelegateProtocol.h"

@class ESView;

@interface ViewController : UIViewController<ESViewDelegate>
{
	ESView *esView;
}

@property (readwrite, retain) ESView *esView;

@end

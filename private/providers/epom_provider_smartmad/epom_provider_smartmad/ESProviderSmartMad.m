//
//  ESProviderSmartMad.m
//  ESProviderSmartMad
//
//  Created by Epom LTD on 9/7/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//

#import "ESProviderSmartMad.h"

#import "EpomSettings.h"

#define APPLICATION_ID_KEY @"APPLICATION_ID"
#define POSITION_ID_KEY @"POSITION_ID"

@interface ESProviderSmartMad ()
@property (readwrite, retain) SmartMadAdView *_adView;
@property (readwrite, retain) NSString *_positionId;

@property (readwrite, assign) AdMeasureType _adMeasure;
@property (readwrite, assign) AdCompileMode _adCompileMode;
@end


@implementation ESProviderSmartMad

@synthesize _adView = adView_;
@synthesize _positionId = positionId_;
@synthesize _adMeasure = adMeasure_;
@synthesize _adCompileMode = adCompileMode_;

+ (BOOL)initializeSystem
{
	return YES;
}

#pragma mark -- overriden methods

- (id)initWithParameters:(NSDictionary *)params sizeType:(ESViewSizeType)size delegate:(id<ESProviderDelegate>)delegate_
{
	self = [super initWithParameters:params sizeType:size delegate:delegate_];
	
	if (self == nil)
	{
		return nil;
	}
	
	self._positionId = [params valueForKey:POSITION_ID_KEY];
	if (self._positionId == nil)
	{
		self._positionId = @"90000005";
	}
	
	NSString *applicationID = [params valueForKey:APPLICATION_ID_KEY];
	if (applicationID == nil)
	{
		applicationID = @"bcc64d52dbcb487";
	}
	[SmartMadAdView setApplicationId:applicationID];
	
	AdMeasureType dimensions[] =
	{
		/*ESViewSize320x50*/ AD_MEASURE_DEFAULT,
		/*ESViewSize768x90*/ TABLET_AD_MEASURE_728X90,
	};
	
	assert(ARRAY_SIZE(dimensions) == ESViewSizeTypeCount);
	self._adMeasure = dimensions[size];
	self._adCompileMode = [self.delegate inTestMode] ? AdDebug : AdRelease;
	
	self._adView = [[[SmartMadAdView alloc] initRequestAdWithDelegate:self] autorelease];
	[self._adView setEventDelegate:self];
			
	return self;
}

- (void)dealloc
{
	self._adView._adEventDelegate = nil;
	self._adView = nil;
	[super dealloc];
}

#pragma mark -- reimplemented methods

- (UIView *)getView
{
	return self._adView;
}

#pragma mark -- SmartMadAdEventDelegate

- (void)adEvent:(SmartMadAdView*)adview  adEventCode:(AdEventCodeType)eventCode
{
	switch (eventCode)
	{
		case EVENT_NEWAD:
			[self.delegate providerDidRecieveAd:self];
			break;
		case EVENT_INVALIDAD:
			ES_LOG_ERROR(@"SmartMad ad request failed. No error or error code provided.");
			[self.delegate providerFailedToRecieveAd:self];
		default:
			break;
	}
}

- (void)adFullScreenStatus:(BOOL)isFullScreen
{
	if (isFullScreen)
	{
		[self.delegate providerViewHasBeenClicked:self];
		[self.delegate providerViewWillEnterModalMode:self];
	}
	else
	{
		[self.delegate providerViewDidLeaveModalMode:self];
	}
}


#pragma mark -- SmartMadAdViewDelegate implementation

-(NSString*)adPositionId
{
	return self._positionId;
}

-(NSTimeInterval)adInterval
{
	return 1e6;
}

-(AdMeasureType)adMeasure
{
	return self._adMeasure;
}

-(AdBannerTransitionAnimationType)adBannerAnimation
{
	return BANNER_ANIMATION_TYPE_FLIPFROMRIGHT;
}

-(AdCompileMode)compileMode
{
	return self._adCompileMode;
}

@end

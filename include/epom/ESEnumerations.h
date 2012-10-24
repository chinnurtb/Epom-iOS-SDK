//
//  ESEnumerations.h
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.



/*
	Available EpomSDK banner view sizes
*/
typedef enum
{
	ESBannerViewSize320x50 	= 0,
	ESBannerViewSize768x90,
	
	ESBannerViewSizeTypeCount // for inner usage
} ESBannerViewSizeType;

/*
 	Interstitial states
 */
typedef enum
{
	ESInterstitialViewStateInitializing = 0,
	ESInterstitialViewStateLoading,
	ESInterstitialViewStateFailed,
	ESInterstitialViewStateReady,
	ESInterstitialViewStateActive,
	ESInterstitialViewStateDone,
	
	ESInterstitialViewStateTypeCount // for inner usage
} ESInterstitialViewStateType;


/*
	EpomSDK log verbose level
*/
typedef enum
{
	ESVerboseAll 	= 0,
	ESVerboseErrorsOnly,
	ESVerboseNone,
	
	ESVerboseTypeCount // for inner usage	
} ESVerboseType;

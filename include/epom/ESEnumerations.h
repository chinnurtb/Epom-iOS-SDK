//
//  ESEnumerations.h
//  Epom SDK
//
//  Created by Epom LTD on 5/31/12.
//  Copyright (c) 2012 Epom LTD. All rights reserved.
//
//	Enumerations used fo creation of ESView

/*
	Available EpomSDK view sizes
*/
typedef enum
{
	ESViewSize320x50 	= 0,
	ESViewSize768x90,
	
	ESViewSizeTypeCount // for inner usage	
} ESViewSizeType;


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

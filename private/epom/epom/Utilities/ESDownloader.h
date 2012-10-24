//
//  ESDownloader.h
//  Epom SDK
//
//  Created by Epom LTD on 9/5/12.
//
//

#import <Foundation/Foundation.h>

@protocol ESDownloaderDelegate;

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum
{
	ESDownloaderStateWorking = 0,
	ESDownloaderStateDone,
	ESDownloaderStateFailed
} ESDownloaderState;

@interface ESDownloader : NSObject<NSURLConnectionDataDelegate>
{
	NSURL *originalURL_;
	NSURLConnection *connection_;
	NSMutableData *downloadedData_;
	ESDownloaderState state_;
	id<ESDownloaderDelegate> delegate_;
}

- (id)initWithURL:(NSURL *)url delegate:(id<ESDownloaderDelegate>)delegate;

- (NSURL *)url;
- (NSData *)data;
- (ESDownloaderState) state;

@property (readonly, assign, getter = url) NSURL *originalURL;
@property (readonly, assign, getter = data) NSData *data;
@property (readonly, assign, getter = state) ESDownloaderState state;

@property (readwrite, assign) id<ESDownloaderDelegate> delegate;

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol ESDownloaderDelegate<NSObject>

@optional
-(void) downloaderDidFinishedDownload:(ESDownloader *)downloader;
-(void) downloader:(ESDownloader *)downloader didFailWithError:(NSError *)error;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////


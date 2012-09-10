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

enum ESDownloaderState
{
	ESDownloaderStateWorking = 0,
	ESDownloaderStateDone,
	ESDownloaderStateFailed
};

@interface ESDownloader : NSObject<NSURLConnectionDataDelegate>
{
	NSURL *originalURL_;
	NSURLConnection *connection_;
	NSMutableData *downloadedData_;
	enum ESDownloaderState state_;
	id<ESDownloaderDelegate> delegate_;
}

- (id)initWithURL:(NSURL *)url delegate:(id<ESDownloaderDelegate>)delegate;

- (NSURL *)url;
- (NSData *)data;
- (enum ESDownloaderState) state;

@property (readonly, assign, getter = url) NSURL *originalURL;
@property (readonly, assign, getter = data) NSData *data;
@property (readonly, assign, getter = state) enum ESDownloaderState state;

@property (readwrite, assign) id<ESDownloaderDelegate> delegate;

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol ESDownloaderDelegate<NSObject>

@optional
-(void) downloaderDidFinishedDownload:(ESDownloader *)downloader;
-(void) downloader:(ESDownloader *)downloader didFailWithError:(NSError *)error;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////


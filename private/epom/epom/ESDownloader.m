//
//  ESDownloader.m
//  Epom SDK
//
//  Created by Epom LTD on 9/5/12.
//
//

#import "ESDownloader.h"

#import "EpomSettings.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// private part

@interface ESDownloader()
@property (readwrite, retain) NSURL *_originalURL;
@property (readwrite, retain) NSURLConnection *_connection;
@property (readwrite, retain) NSMutableData *_downloadedData;
@property (readwrite, assign) BOOL _isDataReady;
@property (readwrite, assign) BOOL _isFailed;
@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// implementation

@implementation ESDownloader

// public
@synthesize delegate = delegate_;

// private
@synthesize _originalURL = originalURL_;
@synthesize _connection = connection_;
@synthesize _downloadedData = downloadedData_;
@synthesize _isDataReady = isDataDownloaded_;
@synthesize _isFailed = isDownloadFailed_;

#pragma mark Public methods implementation

- (id)initWithURL:(NSURL *)url delegate:(id<ESDownloaderDelegate>)delegate
{
	self = [super init];
	if (self == nil)
	{
		return nil;
	}
	
	self.delegate = delegate;
	self._originalURL = url;
	self._downloadedData = [[[NSMutableData alloc] init] autorelease];
	self._connection = [NSURLConnection connectionWithRequest: [NSURLRequest requestWithURL:url] delegate:self];
	return self;
}

- (void)dealloc
{
	self._connection = nil;
	self._originalURL = nil;
	self._downloadedData = nil;
	self.delegate = nil;
	
	[super dealloc];
}

- (NSURL *)url
{
	return self._originalURL;
}

- (NSData *)data
{
	return self._downloadedData;
}

- (enum ESDownloaderState) state
{
	return state_;
}

#pragma mark NSURLConnectionDelegate implementation

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	assert(connection == self._connection);
	state_ = ESDownloaderStateFailed;
	self._connection = nil;
	
	[self.delegate downloader:self didFailWithError:error];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	assert(connection == self._connection);
	state_ = ESDownloaderStateDone;
	self._connection = nil;
	
	[self.delegate downloaderDidFinishedDownload:self];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	assert(connection == self._connection);
	
	[self._downloadedData appendData: data];
}

@end

//
//  ESLoggedWebView.m
//  Epom SDK
//
//  Created by Epom LTD on 8/28/12.
//
//

#import "ESLoggedWebView.h"

#import "EpomSettings.h"

#ifdef DEBUG
//#	define ENABLE_WEBVIEW_LOGGING
#endif

@class WebView;
@class WebScriptCallFrame;

@implementation ESLoggedWebView

#ifdef ENABLE_WEBVIEW_LOGGING
- (void)webView:(id)webView windowScriptObjectAvailable:(id)newWindowScriptObject
{
	[webView setScriptDebugDelegate:self];
}

- (void)webView:(id)webView didClearWindowObject:(id)windowObject forFrame:(WebFrame*)frame
{
	[webView setScriptDebugDelegate:self];
}

#endif // ENABLE_WEBVIEW_LOGGING

#pragma mark -- ScriptDebugDelegate

#ifdef ENABLE_WEBVIEW_LOGGING
- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
       sourceId:(int)sid
    forWebFrame:(WebFrame *)webFrame
{
}

// some source failed to parse
- (void)webView:(WebView *)webView  failedToParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
      withError:(NSError *)error
    forWebFrame:(WebFrame *)webFrame
{
    ES_LOG_ERROR(@"ESLoggedWebView failedToParseSource: url=%@ line=%d error=%@"/*"\nsource=%@"*/, url, lineNumber, error/*, source*/);
}

- (void)webView:(WebView *)webView   exceptionWasRaised:(WebScriptCallFrame *)frame
       sourceId:(int)sid
           line:(int)lineno
    forWebFrame:(WebFrame *)webFrame
{
    ES_LOG_ERROR(@"ESLoggedWebView exception: sid=%d line=%d function=%@, caller=%@, exception=%@",
          sid, lineno, [frame functionName], [frame caller], [frame exception]);
}
#endif // ENABLE_WEBVIEW_LOGGING
@end

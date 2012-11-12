//
//  ESContentBannerView.m
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import "ESContentViewBase.h"
#import "EpomSettings.h"

#import "mraid_js.h"

#import "ESLocationTracker.h"

@interface ESContentViewBase ()

// javascript->Objective-C commands dictionary
@property (readwrite, retain) NSDictionary *_nativeCommands;
// commands queue to process after setVisible(true)
@property (readwrite, retain) NSMutableArray *_commandsAppearQueue;
// source content file, saved to temp folder
@property (readwrite, retain) NSString *_sourceHTMLFilePath;

@end

@implementation ESContentViewBase

// public properties
@synthesize viewState = viewState_;
@synthesize viewPlacement = viewPlacement_;
@synthesize expandProperties = expandProperties_;

// private properties
@synthesize _nativeCommands = nativeCommands_;
@synthesize _commandsAppearQueue = commandsAppearQueue_;
@synthesize _sourceHTMLFilePath = sourceHTMLFilePath_;

- (id)initWithFrame:(CGRect)frame
   expandProperties:(ESContentViewExpandProperties *)expandProperties
	 isInterstitial:(BOOL)isInterstitial
		   autoShow:(BOOL)autoShow
{
	
	self = [super initWithFrame:frame];
	if (self == nil)
	{
		return nil;
	}

	self.delegate = self;
	if ([self respondsToSelector:@selector(setAllowsInlineMediaPlayback:)])
	{
		[self setAllowsInlineMediaPlayback:YES];
	}
	if ([self respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)])
	{
		[self setMediaPlaybackRequiresUserAction:NO];
	}
	
	UIScrollView *scrollView = [[self subviews] lastObject];
	if ([scrollView isKindOfClass:NSClassFromString(@"UIScrollView")])
	{
		scrollView.scrollEnabled = NO;
	}
	
	self._nativeCommands = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSValue valueWithPointer:@selector(log:)], @"log",
						   [NSValue valueWithPointer:@selector(close:)], @"close",
						   [NSValue valueWithPointer:@selector(expand:)], @"expand",
						   [NSValue valueWithPointer:@selector(setExpandProperties:)], @"setExpandProperties",
						   [NSValue valueWithPointer:@selector(open:)], @"open",
						   [NSValue valueWithPointer:@selector(updateGeoLocation:)], @"updateGeoLocation",
						   nil];
	
	self._commandsAppearQueue = [[[NSMutableArray alloc] init] autorelease];
	
	viewPlacement_ = isInterstitial ? ESContentViewPlacementInterstitial : ESContentViewPlacementInline;
	autoShow_ = autoShow;
	
	if (expandProperties != nil)
	{
		expandProperties_ = *expandProperties;
	}
	else
	{
		CGRect rect = epom_screen_size();
		expandProperties_.width = rect.size.width;
		expandProperties_.height = rect.size.height;
	}
	
	return self;
}

- (void)setDerived:(ESContentViewBaseDerived *)derived
{
	derived_ = derived;
}

- (void)dealloc
{
	self.delegate = nil;
	self._nativeCommands = nil;
	self._commandsAppearQueue = nil;
	[self cleanSourceHtmlFile];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[super dealloc];
}
- (id)retain
{
	return [super retain];
}

- (oneway void)release
{
	[super release];
}

- (void)loadContent:(NSString *)content
{
	
    //NSMutableString *mutableContent = [[[NSMutableString alloc] init] autorelease];
	NSMutableString *mutableContent = [[content mutableCopy] autorelease];
	
    if ([content rangeOfString:@"<html>"].location == NSNotFound)
	{
		[mutableContent insertString:@"<html><head></head>"
		 @"<body leftmargin='0'"
		 @"		topmargin='0'"
		 @"		marginwidth='0'"
		 @"		marginheight='0'"
		 @"		style='background-color:transparent; width: 100%%; text-align: center;'>" atIndex:0];
		
		[mutableContent appendString:@"</body></html>"];
	}
	
	NSRange headPos = [mutableContent rangeOfString:@"<head>"];
	[mutableContent replaceCharactersInRange:headPos
								  withString:[NSString stringWithFormat:@"<head><script type='text/javascript'>%s</script>", mraid_js]];

	// save to temp file
	NSString *tempFileName = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.html", [NSDate timeIntervalSinceReferenceDate] * 1000.0]];
	if (YES == [[NSFileManager defaultManager] createFileAtPath:tempFileName
													   contents:[mutableContent dataUsingEncoding:NSUTF8StringEncoding]
													 attributes:nil])
	{
		ASSERT(self._sourceHTMLFilePath == nil);
		
		self._sourceHTMLFilePath = tempFileName;
		[self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self._sourceHTMLFilePath]
										   cachePolicy:NSURLRequestReloadIgnoringCacheData
									   timeoutInterval:60.0]];
	}
	else
	{
		// if cant create file - use loading from string
		[self loadHTMLString:mutableContent baseURL:nil];
	}
}

- (void)show
{
	switch (self.viewPlacement)
	{
		case ESContentViewPlacementInline:
			[self setViewState:ESContentViewStateDefault];
			break;
		case ESContentViewPlacementInterstitial:
			[self setViewState:ESContentViewStateExpanded];
			break;
		default:
			NOENTRY;
	}
	
	[self executeMRAIDCommand:@"setViewable(true)"];
}

- (void)close
{
	[self close:nil];
}

- (void)simulateMRAIDExpanding
{
	[self executeMRAIDCommand:@"setState(\"expanded\")"];
}

- (void)simulateMRAIDShrinking
{
	[self executeMRAIDCommand:@"setState(\"default\")"];
}

#pragma mark -- UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *url = [[request.URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSRange mraidSchemePos = [url rangeOfString:@"mraid://"];
	if ((mraidSchemePos.location != NSNotFound) && (mraidSchemePos.location == 0))
	{
		NSString *command = [url substringFromIndex:mraidSchemePos.length];
		
		[self executeNativeCall:command];
		return NO;
	}
	
	
	if ([url compare:@"about:blank"] == NSOrderedSame)
	{
		// for the case of direct content loading
		return YES;
	}
	else if ((self._sourceHTMLFilePath != nil) && ([url rangeOfString:self._sourceHTMLFilePath].location != NSNotFound))
	{
		// for the case of loading temp file
		return YES;
	}
	else
	{
		[self openEmbeddedWebBrowser:url];
		
		return NO;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if (self.viewState == ESContentViewStateUnknown)
	{
		[self setViewState:ESContentViewStateLoading];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (self.viewState == ESContentViewStateLoading)
	{
		CGRect rect = epom_screen_size();
		[self executeMRAIDCommand:[NSString stringWithFormat:@"updateExpandSize(%0.f, %0.f)",
								   rect.size.width, rect.size.height]];
		
		switch (viewPlacement_)
		{
			case ESContentViewPlacementInline:
				[self executeMRAIDCommand:@"setPlacementType(\"inline\")"];
				break;
			case ESContentViewPlacementInterstitial:
				[self executeMRAIDCommand:@"setPlacementType(\"interstitial\")"];
				break;
			default:
				NOENTRY;
		}
		
		@synchronized(self._commandsAppearQueue)
		{
			NSArray *commands = self._commandsAppearQueue;
			[commands retain];
			self._commandsAppearQueue = nil;
			
			// execute all the queued commands
			for(NSString *cmd in commands)
			{
				[self executeNativeCall:cmd];
			}
			[commands release];
		}
		
		[self executeMRAIDCommand:@"setReady()"];
		
		[derived_ onAdLoadSuccess];
		
		if (autoShow_)
		{
			[self show];
		}
	}
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[derived_ onAdLoadError:error];
}

#pragma mark -- JavaScript functions invocation

- (NSString *)executeMRAIDCommand:(NSString *)command
{
	NSString *js = [NSString stringWithFormat:@"window.mraidback.%@;",command];
    return [self stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark -- MRAID executeNativeCall processing

- (void)executeNativeCall:(NSString *)commandLine
{
	NSRange commandOptionsPos = [commandLine rangeOfString:@"?"];
	
	NSString *command = nil;
	NSString *options = nil;
	
	if (commandOptionsPos.location != NSNotFound)
	{
		command = [commandLine substringWithRange:NSMakeRange(0, commandOptionsPos.location)];
		options = [commandLine substringFromIndex:commandOptionsPos.location + 1];
	}
	else
	{
		command = commandLine;
	}
	
	if (([command compare:@"log"] != NSOrderedSame) && (self._commandsAppearQueue != nil))
	{
		@synchronized(self._commandsAppearQueue)
		{
			// store command to execute it later, after appear
			[self._commandsAppearQueue addObject: commandLine];
		}
		return;
	}
	
	NSValue *selectorValue = [self._nativeCommands objectForKey:command];
	SEL selector = (selectorValue != nil) ? [selectorValue pointerValue] : nil;
	if (selector == nil)
	{
		ES_LOG_ERROR(@"Content provider MRAID: can't find native command processor for command \"%@\".", command);
		
		return;
	}
	
	NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (options)
	{
		NSArray *pairs = [options componentsSeparatedByString:@"&"];
		
		for (NSString * pair in pairs)
		{
			NSRange equalPos = [pair rangeOfString:@"="];
			if (equalPos.location == NSNotFound)
			{
				ES_LOG_ERROR(@"Content provider MRAID: invalid key/value pair \"%@\" for command \"%@\"", pair, command);
				continue;
			}
			
			NSString *key = [pair substringWithRange:NSMakeRange(0, equalPos.location)];
			NSString *value = [[pair substringFromIndex: equalPos.location + 1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[parameters setValue:value forKey:key];
		}
	}
	
	[self performSelector:selector withObject:parameters];
}


#pragma mark -- MRAID callbacks

- (void)log:(NSDictionary *)parameters
{
#ifdef DEBUG
	NSString *type = [parameters objectForKey:@"type"];
	NSString *message = [parameters objectForKey:@"message"];
	
	if (type == nil)
	{
		ES_LOG_ERROR(@"Content provider MRAID: \"log\" command passed without message type. Ignoring command.");
		return;
	}
	if (message == nil)
	{
		ES_LOG_ERROR(@"Content provider MRAID: \"log\" command passed without message. Ignoring command.");
		return;
	}
	
	if ([type compare:@"error"] == NSOrderedSame)
	{
		ES_LOG_ERROR(@"Content provider MRAID: %@", message);
	}
	else if ([type compare:@"info"] == NSOrderedSame)
	{
		ES_LOG_INFO(@"Content provider MRAID: %@", message);
	}
	else
	{
		ES_LOG_ERROR(@"Content provider MRAID: \"log\" command type \"%@\" is unknown. Ignoring command.", type);
	}
#endif // DEBUG
}

- (void)close:(NSDictionary *)parameters
{
	switch (self.viewState)
	{
		case ESContentViewStateDefault:
			[self setViewState:ESContentViewStateHidden];
			break;
		case ESContentViewStateExpanded:
			switch (self.viewPlacement)
			{
				case ESContentViewPlacementInline:
					[self setViewState:ESContentViewStateDefault];
					break;
				case ESContentViewPlacementInterstitial:
					[self setViewState:ESContentViewStateHidden];
					break;
				default:
					NOENTRY;
			}
			break;
		default:
			NOENTRY;
	}
}

- (void)expand:(NSDictionary *)parameters
{
	NSString *url = [parameters valueForKey:@"url"];
	if ([derived_ onExpand:url])
	{
		[self setViewState:ESContentViewStateExpanded];
	}
}

- (void)setExpandProperties:(NSDictionary *)parameters
{
	NSString *widthValue = [parameters valueForKey:@"width"];
	NSString *heightValue = [parameters valueForKey:@"height"];
	NSString *useCustomCloseValue = [parameters valueForKey:@"useCustomClose"];
	NSString *isModalValue = [parameters valueForKey:@"isModal"];
	
	if (widthValue != nil)
	{
		expandProperties_.width = [widthValue intValue];
	}
	
	if (heightValue != nil)
	{
		expandProperties_.height = [heightValue intValue];
	}
	
	if (useCustomCloseValue != nil)
	{
		expandProperties_.useCustomClose = [useCustomCloseValue compare:@"true"] == NSOrderedSame;
	}
	
	// isModal is radonly. here only for debug
	if (isModalValue != nil)
	{
		expandProperties_.isModal = [isModalValue compare:@"true"] == NSOrderedSame;
	}
}

- (void)open:(NSDictionary *)parameters
{
	NSString *urlValue = [parameters valueForKey:@"url"];
	if (urlValue)
	{
		[self openEmbeddedWebBrowser:urlValue];
	}
}

- (void)updateGeoLocation:(NSDictionary *)parameters
{
	CLLocation *location = [[ESLocationTracker shared] currentLocation];
	if (location)
	{
		[self executeMRAIDCommand:[NSString stringWithFormat:@"updateGeoLocation(%0.7f, %0.7f, %0.7f)"
								   , location.coordinate.latitude
								   , location.coordinate.longitude
								   , location.horizontalAccuracy]];
	}
}

#pragma mark -- ESContentWebViewController delegate

- (void) onDismissWebView:(BOOL)leaveApp
{
	if (self.viewState == ESContentViewStateDefault)
	{
		[derived_ onAdDidLeaveModalMode];
	}
	
	if (leaveApp)
	{
		[derived_ onUserInteractionWithWillLeaveApp:YES];
	}
}

#pragma mark -- Private methods

- (void)setViewState:(ESContentViewState)newState
{
	ESContentViewState oldState = viewState_;
	
	[derived_ onBeforeStateChangeFrom:oldState to:newState];
	
	switch (newState)
	{
		case ESContentViewStateUnknown:
			ASSERT(false && "Is initial state. Can't be switched in");
			break;
		case ESContentViewStateLoading:
			[self executeMRAIDCommand:@"setState(\"loading\")"];
			break;
		case ESContentViewStateDefault:
			[self executeMRAIDCommand:@"setState(\"default\")"];
			break;
		case ESContentViewStateExpanded:
			if ([derived_ treatExpandAsUserInteraction])
			{
				[derived_ onUserInteractionWithWillLeaveApp:NO];
			}
			[self executeMRAIDCommand:@"setState(\"expanded\")"];
			break;
			
		case ESContentViewStateHidden:
			[self executeMRAIDCommand:@"setViewable(false)"];
			[self executeMRAIDCommand:@"setState(\"hidden\")"];
			break;
			
		default:
			ASSERT(false);
			break;
	}
	
	viewState_ = newState;
	
	[derived_ onAfterStateChangeFrom:oldState to:newState];
}

- (void)openEmbeddedWebBrowser:(NSString *)url
{
	BOOL willLeaveApp = NO;
	
	if (([url rangeOfString:@"http://"].location != NSNotFound) && ([url rangeOfString:@"https://"].location != NSNotFound))
	{
		willLeaveApp = YES;
		// app links to itunes
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
	else
	{
		if (self.viewState == ESContentViewStateDefault)
		{
			[derived_ onAdWillEnterModalMode];
		}
		UIViewController *controller = [derived_ onControllerForEmbeddedBrowserRequest];
		
		ESContentWebViewController *webViewController = [[[ESContentWebViewController alloc] initWithControls] autorelease];
		
		[controller presentModalViewController:webViewController animated:YES];
		webViewController.delegate = self;
		[webViewController loadBrowser: [NSURL URLWithString:url]];	
	}
	
	[derived_ onUserInteractionWithWillLeaveApp:willLeaveApp];
}

- (void)cleanSourceHtmlFile
{
	if (self._sourceHTMLFilePath != nil)
	{
		[[NSFileManager defaultManager] removeItemAtPath:self._sourceHTMLFilePath error:nil];
		self._sourceHTMLFilePath = nil;
	}
}

@end

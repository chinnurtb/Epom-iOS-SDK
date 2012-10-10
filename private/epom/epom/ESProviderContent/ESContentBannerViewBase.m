//
//  ESContentBannerView.m
//  Epom SDK
//
//  Created by Epom LTD on 8/27/12.
//
//

#import "ESContentBannerViewBase.h"
#import "EpomSettings.h"

#import "mraid_js.h"

#import "CoreLocation/CLLocation.h"

@interface ESContentBannerViewBase ()

// root view controller
@property (readwrite, assign) UIViewController *_modalViewController;

// javascript->Objective-C commands dictionary
@property (readwrite, retain) NSDictionary *_nativeCommands;
// commands queue to process after setVisible(true)
@property (readwrite, retain) NSMutableArray *_commandsAppearQueue;
// source content file, saved to temp folder
@property (readwrite, retain) NSString *_sourceHTMLFilePath;

@property (setter = setState:, getter = state, assign) enum ESContentBannerViewState _state;
@property (setter = setPlacement:, getter = placement, assign) enum ESContentBannerViewPlacement _placement;

@end

@implementation ESContentBannerViewBase

// public properties
@synthesize state = state_;
@synthesize placement = placement_;
@synthesize expandProperties = expandProperties_;

// private properties
@synthesize _modalViewController = modalViewController_;
@synthesize _nativeCommands = nativeCommands_;
@synthesize _commandsAppearQueue = commandsAppearQueue_;
@synthesize _sourceHTMLFilePath = sourceHTMLFilePath_;

- (id)initWithFrame:(CGRect)frame modalViewController:(UIViewController *)controller expandProperties:(struct ESContentBannerViewExpandProperties *)expandProperties
{
	
	self = [super initWithFrame:frame];
	if (self == nil)
	{
		return nil;
	}

	self._modalViewController = controller;
	
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
	
	if (expandProperties != nil)
	{
		expandProperties_ = *expandProperties;
		autoexpandOnAppear_ = YES;
	}
	
	return self;
}

- (void)setDerived:(ESContentBannerViewBaseDerived *)derived
{
	derived_ = derived;
}

- (void)dealloc
{
	self.state = ESContentBannerViewStateHidden;
	
	self.delegate = nil;
	self._modalViewController = nil;
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
		 @"		onload='mraid.logEntry(\"Greetings\");'"
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
		assert(self._sourceHTMLFilePath == nil);
		
		self._sourceHTMLFilePath = tempFileName;
		[self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self._sourceHTMLFilePath]]];
	}
	else
	{
		// if cant create file - use loading from string
		[self loadHTMLString:mutableContent baseURL:nil];
	}
}

- (void)closeExpandedView
{
	if (self.state == ESContentBannerViewStateExpanded)
	{
		self.state = ESContentBannerViewStateDefault;
	}
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
	if (self.state == ESContentBannerViewStateUnknown)
	{
		self.state = ESContentBannerViewStateLoading;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self cleanSourceHtmlFile];
	
	if (self.state == ESContentBannerViewStateLoading)
	{
		self.state = ESContentBannerViewStateDefault;
		self.placement = ESContentBannerViewPlacementInline;
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self cleanSourceHtmlFile];
	
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
	
	if (([command compare:@"log"] != NSOrderedSame) && (self.superview == nil))
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
	switch (self.state)
	{
		case ESContentBannerViewStateDefault:
			self.state = ESContentBannerViewStateHidden;
			break;
		case ESContentBannerViewStateExpanded:
			self.state = ESContentBannerViewStateDefault;
			break;
		default:
			break;
	}
}

- (void)expand:(NSDictionary *)parameters
{
	
	if (self.state != ESContentBannerViewStateDefault)
	{
		return;
	}
	NSString *url = [parameters valueForKey:@"url"];
	
	[derived_ onAdHasBeenTapped];
	
	if ([derived_ onExpand:url])
	{
		self._state = ESContentBannerViewStateExpanded;
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
	CLLocation *location = [derived_ onGeoLocationRequest];
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
	if (self.state == ESContentBannerViewStateDefault)
	{
		[derived_ onAdDidLeaveModalMode];
	}
	
	if (leaveApp)
	{
		[derived_ onAdWillLeaveApp];
	}
}

#pragma mark -- Private methods

- (enum ESContentBannerViewState)state
{
	return state_;
}

- (void)setState:(enum ESContentBannerViewState)newState
{
	if (newState == state_)
	{
		return;
	}
	
	enum ESContentBannerViewState oldState = state_;
	
	[derived_ onBeforeStateChangeFrom:oldState to:newState];
	
	switch (newState)
	{
		case ESContentBannerViewStateUnknown:
			assert(false && "Is initial state. Can't be switched in");
			break;
		case ESContentBannerViewStateLoading:
			break;
		case ESContentBannerViewStateDefault:
			switch (oldState)
		{
			case ESContentBannerViewStateLoading:
			{
				CGRect screenRect = self._modalViewController.view.frame;
				
				[self executeMRAIDCommand:[NSString stringWithFormat:@"updateExpandSize(%0.f, %0.f)",
										   screenRect.size.width, screenRect.size.height]];
				[self executeMRAIDCommand:@"setReady()"];
				[self performSelector:@selector(appear) withObject:nil afterDelay:0.5]; // preloading time
				break;
				
			}
			case ESContentBannerViewStateExpanded:				
				break;
			default:
				break;
		}
			[self executeMRAIDCommand:@"setState(\"default\")"];
			break;
		case ESContentBannerViewStateExpanded:
			[self executeMRAIDCommand:@"setState(\"expanded\")"];
		break;
			
		case ESContentBannerViewStateHidden:
			[self executeMRAIDCommand:@"setViewable(false)"];
			[self executeMRAIDCommand:@"setState(\"hidden\")"];
			
			// force skip ad and load next
			if (autoexpandOnAppear_ == NO)
			{
				[self webView:self didFailLoadWithError:nil];
			}
			break;
			
		default:
			assert(false);
			break;
	}
	
	state_ = newState;
	
	[derived_ onAfterStateChangeFrom:oldState to:newState];
}

- (enum ESContentBannerViewPlacement)placement
{
	return placement_;
}

- (void)setPlacement:(enum ESContentBannerViewPlacement)newPlacement
{
	if (newPlacement == placement_)
	{
		return;
	}
	
	switch (newPlacement)
	{
		case ESContentBannerViewPlacementUnknown:
			assert(false && "Is initial placement. Can't be switched in");
			break;
		case ESContentBannerViewPlacementInline:
			[self executeMRAIDCommand:@"setPlacementType(\"inline\")"];
			break;
		case ESContentBannerViewPlacementInterstitial:
			[self executeMRAIDCommand:@"setPlacementType(\"interstitial\")"];
			break;
		default:
			assert(false);
			break;
	}
	
	placement_ = newPlacement;
}

- (UIViewController *)rootViewController
{
	return self._modalViewController;
}

- (void)openEmbeddedWebBrowser:(NSString *)url
{
	if (self.state == ESContentBannerViewStateDefault)
	{
		[derived_ onAdHasBeenTapped];
	}
	
	if (([url rangeOfString:@"itunes://"].location != NSNotFound) ||
		([url rangeOfString:@"http://itunes.apple.com"].location != NSNotFound))
	{
		// app links to itunes
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
	else
	{
		if (self.state == ESContentBannerViewStateDefault)
		{
			[derived_ onAdWillEnterModalMode];
		}
		UIViewController *controller = [derived_ onControllerForEmbeddedBrowserRequest];
		
		ESContentWebViewController *webViewController = [[[ESContentWebViewController alloc] initWithControls] autorelease];
		
		[controller presentModalViewController:webViewController animated:YES];
		webViewController.delegate = self;
		[webViewController loadBrowser: [NSURL URLWithString:url]];	
	}
}

- (void)appear
{
	[derived_ onAdLoadSuccess];
	
	[self executeMRAIDCommand:@"setViewable(true)"];
	
	@synchronized(self._commandsAppearQueue)
	{
		// execute all the queued commands
		for(NSString *cmd in self._commandsAppearQueue)
		{
			[self executeNativeCall:cmd];
		}
		
		self._commandsAppearQueue = nil;
	}
	
	if (autoexpandOnAppear_)
	{
		self.state = ESContentBannerViewStateExpanded;
	}
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

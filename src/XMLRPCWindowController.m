//
//  XMLRPCWindowController.m
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 11/1/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import "XMLRPCWindowController.h"
#import "XMLRPCService.h"
#import "DHTMLPrettyPrinter.h"
#import "FaultChecker.h"
#import "PreferenceController.h"
#import "RancheroXMLRPCServiceImpl.h"

static NSString *EmptyString = @"";
static NSString *ResponseObjectFormat = @"<html><body><pre style='font:13px LucidaGrande;'>%@</pre></body></html>";

@interface XMLRPCWindowController (Private)
- (void)setupXMLRPCService;
- (void)setupDefaultWindowButton;
- (void)setupParamsTextFont;
- (void)setupPrettyPrinter;
- (void)setupFaultChecker;
- (void)setupObjectResponseTextFont;
- (void)makeNewWindowSameSizeAsLastWindow;

- (void)paramEvalExceptionOcurred:(NSException *)e;
- (void)prettyPrinterDidFinishParsing:(NSDictionary *)userInfo;

- (void)setButtonToStop;
- (void)setButtonToExecute;
- (void)setWindowTitle;
- (void)startProgressAnimation;
- (void)stopProgressAnimation;
- (void)displayDuration;

- (NSString *)escapeXML:(NSString *)xmlSource;

- (void)playSuccessSound;
- (void)playFailureSound;
- (BOOL)soundEnabled;
- (void)playSoundWithName:(NSString *)name;
- (void)playSoundForXMLResponse:(NSString *)responseXML;
- (BOOL)missingUriOrMethod;
@end

@implementation XMLRPCWindowController

- (id)initWithWindowNibName:(NSString *)nibName {
    self = [super initWithWindowNibName:nibName];
    if (self) {
		[self setupXMLRPCService];
		[self setupPrettyPrinter];
		[self setupFaultChecker];
    }
    return self;
}

- (void)dealloc {
	[service release];
	[prettyPrinter release];
	[faultChecker release];
	[responseXML release];
	[responseObjectString release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSWindowController

- (void)windowDidLoad {
	[self setupDefaultWindowButton];
	[self setupParamsTextFont];
	[self makeNewWindowSameSizeAsLastWindow];
	[self setupObjectResponseTextFont];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
	NSString *uri = [uriField stringValue];
	NSString *method = [methodField stringValue];
	if ((!uri || 0 == [uri length]) && (!method || 0 == [method length])) {
		return [super windowTitleForDocumentDisplayName:displayName];
	}
	return [NSString stringWithFormat:@"URI: %@ | Method: %@", [uriField stringValue], [methodField stringValue]];
}

#pragma mark -
#pragma mark Action

- (IBAction)clear:(id)sender {
	[xmlRequestView reload:self];
	[xmlResponseView reload:self];
	[objectResponseView setString:EmptyString];
	[statusField setStringValue:EmptyString];
}

- (IBAction)execute:(id)sender {
	if ([self missingUriOrMethod]) {
		NSBeep();
		return;
	}
	
	[self clear:self];
	[self startProgressAnimation];
	[self setButtonToStop];
	
	stopped = NO;
	
	[self setWindowTitle];
	[service setURLString:[uriField stringValue]];
	
	[service executeAsync:[methodField stringValue]
		  withParamString:[paramsText string]];
}

- (IBAction)stop:(id)sender {
	stopped = YES;
	[self setButtonToExecute];
	[self clear:self];
	[self stopProgressAnimation];
}

- (IBAction)switchTab:(id)sender {
	[tabView selectTabViewItemAtIndex:[sender tag]];
}

#pragma mark -
#pragma mark Private

- (void)setupXMLRPCService {
	service = [[RancheroXMLRPCServiceImpl alloc] initWithDelegate:self];
}

- (void)setupDefaultWindowButton {
	[[self window] setDefaultButtonCell:[executeButton cell]];
}

- (void)setupParamsTextFont {
	[paramsText setFont:[NSFont fontWithName:@"Monaco" size:11.0]];
}

- (void)setupPrettyPrinter {
	prettyPrinter = [[DHTMLPrettyPrinter alloc] initWithDelegate:self];
}

- (void)setupFaultChecker {
	faultChecker = [[FaultChecker alloc] init];
}

- (void)setupObjectResponseTextFont {
	[objectResponseView setFont:[NSFont fontWithName:@"Monaco" size:11]];
}

- (void)setButtonToStop {
	@synchronized (executeButton) {
		[executeButton setAction:@selector(stop:)];
		[executeButton setTitle:@"Stop"];
		[executeButton setNeedsDisplay:YES];
	}
}

- (void)setButtonToExecute {
	@synchronized (executeButton) {
		[executeButton setAction:@selector(execute:)];
		[executeButton setTitle:@"Execute"];
		[executeButton setNeedsDisplay:YES];
	}
}

- (void)setWindowTitle {
	[[self window] setTitle:[self windowTitleForDocumentDisplayName:nil]];
}

- (void)startProgressAnimation {
	[progressIndicator startAnimation:self];
}

- (void)stopProgressAnimation {
	[progressIndicator stopAnimation:self];
}

- (void)displayDuration {
	NSString *label = [NSString stringWithFormat:@"%.2f seconds", [self duration]];
	[statusField setStringValue:[label substringFromIndex:1]];
}

- (NSString *)escapeXML:(NSString *)xmlSource {
	NSMutableString *result = [NSMutableString stringWithString:xmlSource];
	
	[result replaceOccurrencesOfString:@"<"
							withString:@"&lt;"
							   options:NSCaseInsensitiveSearch
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@">"
							withString:@"&gt;"
							   options:NSCaseInsensitiveSearch
								 range:NSMakeRange(0, [result length])];	
	return result;
}

- (void)makeNewWindowSameSizeAsLastWindow {
	NSWindow *lastMainWin = [[NSApplication sharedApplication] mainWindow];
	if (lastMainWin) {
		NSWindow *newMainWin = [self window];
		NSRect rect   = [[lastMainWin contentView] bounds];
		NSRect screen = [[lastMainWin screen] frame];
		[newMainWin setContentSize:rect.size];
		rect = [newMainWin frame];
		if (!NSContainsRect(screen, rect)) {
			[newMainWin center];
		}
	}
}

- (BOOL)missingUriOrMethod {
	NSString *uriString		= [uriField stringValue];
	NSString *methodString	= [methodField stringValue];
	return !uriString 
		|| !methodString 
		|| [uriString length] == 0 
		|| [methodString length] == 0;
}

#pragma mark -
#pragma mark Sound

- (void)playSuccessSound {
	if ([self soundEnabled]) {
		[self playSoundWithName:[[NSUserDefaults standardUserDefaults] stringForKey:SuccessSoundNameKey]];
	}
}

- (void)playFailureSound {
	if ([self soundEnabled]) {
		[self playSoundWithName:[[NSUserDefaults standardUserDefaults] stringForKey:FailureSoundNameKey]];
	}
}

- (BOOL)soundEnabled {
	return [[NSUserDefaults standardUserDefaults] boolForKey:PlaySoundKey];
}

- (void)playSoundWithName:(NSString *)name {
	[[NSSound soundNamed:name] play];
}

- (void)playSoundForXMLResponse:(NSString *)resXML {
	if (![self soundEnabled]) {
		return;
	}
	if (!resXML || 0 == [resXML length]) {
		[self playFailureSound];
		return;
	}
	@try {
		if ([faultChecker XMLRPCResponseStringContainsFault:resXML]) {
			[self playFailureSound];
		} else {
			[self playSuccessSound];
		}
	} @catch (NSException *e) {
		[self playFailureSound];
	}
}

#pragma mark -
#pragma mark XMLRPCDelegate

- (void)rpcCallbackWithRequestXMLString:(NSString *)reqXML
					  responseXMLString:(NSString *)resXML
				   responseObjectString:(NSString *)responseObjectStr
							   duration:(double)d {
	if (stopped) return;
	
	[self setResponseXML:resXML];
	[self setResponseObjectString:responseObjectStr];
	[self setDuration:d];
	
	[prettyPrinter parseRequest:reqXML resonse:resXML];
}

- (void)paramEvalExceptionOcurred:(NSException *)e {
	NSString *errorSource = [NSString stringWithFormat:ResponseObjectFormat, [e reason]];
	[[xmlRequestView   mainFrame] loadHTMLString:errorSource baseURL:nil];
	[[xmlResponseView  mainFrame] loadHTMLString:errorSource baseURL:nil];
	
	[self stopProgressAnimation];
	[self setButtonToExecute];
	[self playFailureSound];
}

#pragma mark -
#pragma mark DHTMLPrettyPrinterDelegate

- (void)prettyPrinterDidFinishParsing:(NSDictionary *)userInfo {
	NSString *requestSource  = [userInfo objectForKey:RequestKey];
	NSString *responseSource = [userInfo objectForKey:ResponseKey];
	//NSString *objectSource = [NSString stringWithFormat:ResponseObjectFormat, [self escapeXML:responseObjectString]];
	NSString *objectSource   = responseObjectString;
		
	[[xmlRequestView   mainFrame] loadHTMLString:requestSource  baseURL:nil];
	[[xmlResponseView  mainFrame] loadHTMLString:responseSource baseURL:nil];
	[objectResponseView setString:objectSource];
	
	[self stopProgressAnimation];
	[self displayDuration];
	[self setButtonToExecute];
	[self playSoundForXMLResponse:responseXML];
}

#pragma mark -
#pragma mark Accessors

- (NSString *)responseXML {
	return responseXML;
}

- (void)setResponseXML:(NSString *)s {
	if (responseXML != s) {
		[responseXML release];
		responseXML = [s retain];
	}
}

- (NSString *)responseObjectString {
	return responseObjectString;
}

- (void)setResponseObjectString:(NSString *)s {
	if (responseObjectString != s) {
		[responseObjectString release];
		responseObjectString = [s retain];
	}
}

- (double)duration {
	return duration;
}

- (void)setDuration:(double)d {
	duration = d;
}

@end

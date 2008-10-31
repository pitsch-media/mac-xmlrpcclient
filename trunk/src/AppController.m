#import "AppController.h"
#import "RancheroXMLRPCServiceImpl.h"

static const NSString *XMLRequestTabID		= @"XMLRequestTab";
static const NSString *XMLResponseTabID		= @"XMLResponseTab";
static const NSString *ObjectResponseTabID	= @"ObjectResponseTab";

static const NSString *EmptyString = @"";
static const NSString *ResponseObjectFormat 
	= @"<html><body><pre style='font:13px LucidaGrande;'>%@</pre></body></html>";


@implementation AppController

#pragma mark -
#pragma mark Class methods
+ (void)initialize 
{
	[self initializeUserDefaults];
}

+ (void)initializeUserDefaults
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithBool:PlaySoundValue] 
					  forKey:PlaySoundKey];
	[defaultValues setObject:SuccessSoundNameValue  
					  forKey:SuccessSoundNameKey];
	[defaultValues setObject:FailureSoundNameValue
					  forKey:FailureSoundNameKey];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


#pragma mark -
#pragma mark init methods
- (id)init
{
	self = [super init];
	[self initXMLRPCService];
	[self initPrettyPrinter];
	return self;
}

- (void)dealloc
{
	[service release];
	[prettyPrinter release];
	[prefController release];
	[super dealloc];
}

#pragma mark -
#pragma mark Awake from Nib methods
- (void)awakeFromNib
{
	[self initDefaultWindowButton];
	[self initParamsTextFont];
}

- (void)initXMLRPCService
{
	service = [[RancheroXMLRPCServiceImpl alloc] initWithDelegate:self];
}

- (void)initDefaultWindowButton
{
	[mainWin setDefaultButtonCell:[executeButton cell]];
}

- (void)initParamsTextFont
{
	[paramsText setFont:[NSFont fontWithName:@"Monaco" size:11.0]];
}

- (void)initPrettyPrinter
{
	prettyPrinter = [[DHTMLPrettyPrinter alloc] init];
}

#pragma mark -
#pragma mark Action methods
- (IBAction)showPreferencePanel:(id)sender
{
	if (!prefController) {
		prefController = [[PreferenceController alloc] init];
	}
	[prefController showWindow:self];
}

- (IBAction)clearResults:(id)sender
{
	[xmlRequestView reload:self];
	[xmlResponseView reload:self];
	[codeResponseView reload:self];
	[statusField setStringValue:EmptyString];
}

- (IBAction)execute:(id)sender
{
	[self startProgressAnimation];
	[executeButton setEnabled:NO];
	[self clearResults:self];

	stopped = NO;

	NSString *endPointURIString = [uriField stringValue];
	[mainWin setTitle:endPointURIString];
	[service setURLString:endPointURIString];

	[service executeAsync:[methodField stringValue]
		  withParamString:[paramsText string]];
}

- (IBAction)stop:(id)sender
{
	stopped = YES;
	[executeButton setEnabled:YES];
	[self clearResults:self];
	[self stopProgressAnimation];
}

- (IBAction)switchToXMLRequestTab:(id)sender
{
	[tabView selectTabViewItemWithIdentifier:XMLRequestTabID];
}

- (IBAction)switchToXMLResponseTab:(id)sender
{
	[tabView selectTabViewItemWithIdentifier:XMLResponseTabID];
}

- (IBAction)switchToObjectResponseTab:(id)sender
{
	[tabView selectTabViewItemAtIndex:2];
}


#pragma mark -
#pragma mark XMLRPCDelegate Methods
- (void)rpcCallbackWithRequestXMLString:(NSString *)requestXML
					  responseXMLString:(NSString *)responseXML
				   responseObjectString:(NSString *)responseObjectString
							   duration:(double)duration
{
	NSLog(@"all done");
	if (stopped) return;
	[self displayDuration:duration];
	
	NSString *requestSource  = [prettyPrinter parse:requestXML];
	NSString *responseSource = [prettyPrinter parse:responseXML];
	NSString *codeSource     = 
		[NSString stringWithFormat:ResponseObjectFormat,[self escapeXML:responseObjectString]];

	[[xmlRequestView   mainFrame] loadHTMLString:requestSource  baseURL:nil];
	[[xmlResponseView  mainFrame] loadHTMLString:responseSource baseURL:nil];
	[[codeResponseView mainFrame] loadHTMLString:codeSource		baseURL:nil];

	[self playSoundForXMLResponse:responseXML];
	[self stopProgressAnimation];
	[executeButton setEnabled:YES];
}

- (void)paramEvalExceptionOcurred:(NSException *)e
{
	NSString *errorSource = [NSString stringWithFormat:ResponseObjectFormat,[e reason]];
	[[xmlRequestView   mainFrame] loadHTMLString:errorSource baseURL:nil];
	[[xmlResponseView  mainFrame] loadHTMLString:errorSource baseURL:nil];
	[[codeResponseView mainFrame] loadHTMLString:errorSource baseURL:nil];
	
	[self stopProgressAnimation];
	[executeButton setEnabled:YES];
	[self playFailureSound];
}

#pragma mark -
#pragma mark Other Methods
- (void)startProgressAnimation
{
	[progressIndicator startAnimation:self];
}

- (void)stopProgressAnimation
{
	[progressIndicator stopAnimation:self];
}

- (void)displayDuration:(double)duration
{
	NSString *label = [NSString stringWithFormat:@"%.2f seconds",duration];
	[statusField setStringValue:[label substringFromIndex:1]];
}

- (NSString *)escapeXML:(NSString *)xmlSource
{
	NSMutableString *result = [NSMutableString stringWithString:xmlSource];
	
	[result replaceOccurrencesOfString:@"<"
							withString:@"&lt;"
							   options:NSCaseInsensitiveSearch
								 range:NSMakeRange(0,[result length])];
	[result replaceOccurrencesOfString:@">"
							withString:@"&gt;"
							   options:NSCaseInsensitiveSearch
								 range:NSMakeRange(0,[result length])];	
	return result;
}


#pragma mark -
#pragma mark Sound methods
- (void)playSuccessSound 
{
	if ([self soundEnabled]) {
		[self playSoundWithName:[[NSUserDefaults standardUserDefaults] 
										stringForKey:SuccessSoundNameKey]];
	}
}

- (void)playFailureSound 
{
	if ([self soundEnabled]) {
		[self playSoundWithName:[[NSUserDefaults standardUserDefaults] 
										stringForKey:FailureSoundNameKey]];
	}
}

- (BOOL)soundEnabled 
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:PlaySoundKey];
}

- (void)playSoundWithName:(NSString *)name 
{
	[[NSSound soundNamed:name] play];
}

- (void)playSoundForXMLResponse:(NSString *)responseXML
{
	if (![self soundEnabled]) {
		return;
	}
	//NSLog(@"responseXML: %@",responseXML);
	NSString *soundName;
	@try 
	{
		NSError *err = nil;
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithXMLString:responseXML
															  options:NSXMLDocumentTidyXML
																error:&err];
		if (!doc) {
			[self playFailureSound];
		} else {
			NSArray *faults = [doc nodesForXPath:@"//fault" error:nil];
			if (faults && [faults count] > 0) {
				[self playFailureSound];
			} else {
				[self playSuccessSound];
			}
		}
		
	}
	@catch (NSException *e) 
	{
		[self playFailureSound];
	}
}


#pragma mark -
#pragma mark NSApplication Delegate Methods
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end

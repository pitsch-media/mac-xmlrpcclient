//
//  XMLRPCWindowController.h
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 11/1/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@protocol XMLRPCService;
@class DHTMLPrettyPrinter;
@class FaultChecker;

@interface XMLRPCWindowController : NSWindowController {
    IBOutlet NSButton *executeButton;
    IBOutlet NSTextField *methodField;
    IBOutlet NSText *paramsText;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *statusField;
    IBOutlet NSTabView *tabView;
    IBOutlet NSTextField *uriField;
    IBOutlet WebView *xmlRequestView;
    IBOutlet WebView *xmlResponseView;
    IBOutlet NSTextView *objectResponseView;
	
	id <XMLRPCService> service;
	DHTMLPrettyPrinter *prettyPrinter;
	FaultChecker *faultChecker;
	BOOL stopped;
	
	NSString *responseXML;
	NSString *responseObjectString;
	double duration;
}

- (IBAction)switchTab:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)execute:(id)sender;
- (IBAction)stop:(id)sender;

- (NSString *)responseXML;
- (void)setResponseXML:(NSString *)s;

- (NSString *)responseObjectString;
- (void)setResponseObjectString:(NSString *)s;

- (double)duration;
- (void)setDuration:(double)duration;
@end

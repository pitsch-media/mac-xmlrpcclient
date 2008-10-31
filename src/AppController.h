/* AppController */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "PreferenceController.h"
#import "XMLRPCService.h"
#import "DHTMLPrettyPrinter.h"

@interface AppController : NSObject
{
    IBOutlet PreferenceController *prefController;
    IBOutlet NSButton *executeButton;
    IBOutlet NSWindow *mainWin;
    IBOutlet NSTextField *methodField;
    IBOutlet NSText *paramsText;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *statusField;
    IBOutlet NSTabView *tabView;
    IBOutlet NSTextField *uriField;
    IBOutlet WebView *xmlRequestView;
    IBOutlet WebView *xmlResponseView;
    IBOutlet WebView *codeResponseView;
	
	id <XMLRPCService> *service;
	DHTMLPrettyPrinter *prettyPrinter;	
	BOOL stopped;
}
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)clearResults:(id)sender;
- (IBAction)execute:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)switchToXMLRequestTab:(id)sender;
- (IBAction)switchToXMLResponseTab:(id)sender;
- (IBAction)switchToObjectResponseTab:(id)sender;
@end

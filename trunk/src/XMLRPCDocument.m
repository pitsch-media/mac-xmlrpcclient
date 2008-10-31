//
//  XMLRPCDocument.m
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/25/05.
//  Copyright Todd Ditchendorf 2005 . All rights reserved.
//

#import "XMLRPCDocument.h"
#import "PreferenceController.h"
#import "XMLRPCWindowController.h"

@interface XMLRPCDocument (Private)
+ (void)initializeUserDefaults;
@end

@implementation XMLRPCDocument

+ (void)initialize {
	[self initializeUserDefaults];
}

+ (void)initializeUserDefaults {
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
#pragma mark NSDocument

- (void)makeWindowControllers {
    NSWindowController *controller = nil;
	controller = [[[XMLRPCWindowController alloc] initWithWindowNibName:@"XMLRPCWindow"] autorelease];
	[self addWindowController:controller];
}

- (BOOL)isDocumentEdited {
	return NO;
}

@end

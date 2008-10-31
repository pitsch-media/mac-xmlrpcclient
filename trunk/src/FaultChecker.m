//
//  FaultChecker.m
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/25/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import "FaultChecker.h"

static const NSString *FaultElementName = @"fault";
static const int FaultElementIndex = 2;

@implementation FaultChecker

- (BOOL)XMLRPCResponseStringContainsFault:(NSString *)response {	
	NSData *data = [response dataUsingEncoding:NSASCIIStringEncoding];

	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
	[parser setDelegate:self];
	
	[parser parse];
	return containsFault;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	tagCount = 0;
	containsFault = NO;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
										namespaceURI:(NSString *)namespaceURI 
									   qualifiedName:(NSString *)qualifiedName 
										  attributes:(NSDictionary *)attributeDict {
	if (++tagCount > 2) {
		[parser abortParsing];
		containsFault = NO;
	}
	
	if ([FaultElementName isEqualToString:elementName]) {
		[parser abortParsing];
		containsFault = YES;
	}
}

@end

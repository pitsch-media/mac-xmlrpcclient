//
//  DHTMLPrettyPrinter.m
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/10/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import "DHTMLPrettyPrinter.h"

NSString *RequestKey  = @"RequestKey";
NSString *ResponseKey = @"ResponseKey";
NSString *PrettyPrinterKey = @"PrettyPrinterKey";

@implementation DHTMLPrettyPrinter

- (id)initWithDelegate:(id)aDelegate {
	self = [super init];
	if (self) {
		[self setDelegate:aDelegate];
	}
	return self;
}

- (void)parseRequest:(NSString *)requestStr resonse:(NSString *)responseStr {
	finishCount = 0;
	
	reqResultStr = [[NSMutableString alloc] init];
	resResultStr = [[NSMutableString alloc] init];
	
	reqData = [requestStr dataUsingEncoding:NSASCIIStringEncoding];
	resData = [responseStr dataUsingEncoding:NSASCIIStringEncoding];

	[NSThread detachNewThreadSelector:@selector(doParse:) toTarget:self withObject:reqData];
	[NSThread detachNewThreadSelector:@selector(doParse:) toTarget:self withObject:resData];
}

- (void)doParse:(NSData *)data {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
	if (data == reqData) {
		reqParser = parser;
	} else {
		resParser = parser;
	}
	[parser setDelegate:self];
	[parser parse];
	
	[pool release];
}

- (NSString *)contentsOfResourceWithName:(NSString *)name ofType:(NSString *)type {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:name ofType:type];
    NSURL *furl = [NSURL fileURLWithPath:path];
	return [NSString stringWithContentsOfURL:furl encoding:NSUTF8StringEncoding error:nil];
}

- (NSMutableString *)resultStringForParser:(NSXMLParser *)parser {
	return (parser == reqParser) ? reqResultStr : resResultStr;
}

- (void)callbackDelegate {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		reqResultStr, RequestKey, resResultStr, ResponseKey, self, PrettyPrinterKey, nil];

	[[self delegate] performSelectorOnMainThread:@selector(prettyPrinterDidFinishParsing:) withObject:userInfo waitUntilDone:NO];
	//[reqResultStr release];
	//[resResultStr release];
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSString *header = [self contentsOfResourceWithName:@"prettyPrintStart" ofType:@"html"];

	[[self resultStringForParser:parser] appendString:header];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	finishCount++;
	NSString *footer = [self contentsOfResourceWithName:@"prettyPrintEnd" ofType:@"html"];
	
	[[self resultStringForParser:parser] appendString:footer];
	if (finishCount == 2) {
		[self callbackDelegate];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
										namespaceURI:(NSString *)namespaceURI 
									   qualifiedName:(NSString *)qName 
										  attributes:(NSDictionary *)attrs {
	NSString *openStartTagFormat = [self contentsOfResourceWithName:@"openStartTag" ofType:@"html"];
	NSString *closeStartTagStr	 = [self contentsOfResourceWithName:@"closeStartTag" ofType:@"html"];
	[[self resultStringForParser:parser] appendFormat:openStartTagFormat,elementName];
//	[self handleAttrs:attrs];
	[[self resultStringForParser:parser] appendFormat:closeStartTagStr,elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
									  namespaceURI:(NSString *)namespaceURI 
									 qualifiedName:(NSString *)qName {
	NSString *endTagFormat = [self contentsOfResourceWithName:@"endTag" ofType:@"html"];
	[[self resultStringForParser:parser] appendFormat:endTagFormat,elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[[self resultStringForParser:parser] appendString:string];
}

#pragma mark -
#pragma mark Accessor methods

- (id)delegate {
	return delegate;
}

- (void)setDelegate:(id)newDelegate {
	if (delegate != newDelegate) {
		[delegate release];
		delegate = [newDelegate retain];
	}
}

@end

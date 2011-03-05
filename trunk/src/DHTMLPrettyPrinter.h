//
//  DHTMLPrettyPrinter.h
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/10/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *RequestKey;
extern NSString *ResponseKey;
extern NSString *PrettyPrinterKey;

@interface DHTMLPrettyPrinter : NSObject <NSXMLParserDelegate> {
	id delegate;
	NSXMLParser *reqParser;
	NSXMLParser *resParser;
	NSMutableString *reqResultStr;
	NSMutableString *resResultStr;
	NSData *reqData;
	NSData *resData;
	int finishCount;
}

- (id)initWithDelegate:(id)delegate;
- (void)parseRequest:(NSString *)requestStr resonse:(NSString *)responseStr;

- (id)delegate;
- (void)setDelegate:(id)delegate;

@end

@interface NSObject (DHTMLPrettyPrinterDelegate) 

- (void)prettyPrinterDidFinishParsing:(NSDictionary *)userInfo;

@end


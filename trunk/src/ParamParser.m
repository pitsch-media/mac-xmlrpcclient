//
//  XMLRPCUtils.m
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/8/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import "ParamParser.h"
#import "GSNSDataExtensions.h"

@interface ParamParser (PrivateMethods)
- (void)setupWebView;
- (BOOL)javaScriptEvalErrorOcurred;
- (id)processParamItem:(id)item;
- (NSArray *)convertToArray:(WebScriptObject *)obj;
- (NSDate *)convertToDate:(WebScriptObject *)obj;
- (NSData *)convertToBase64:(WebScriptObject *)obj;
- (NSData *)convertToBase64Encode:(WebScriptObject *)obj;
- (NSDictionary *)convertToDictionary:(WebScriptObject *)obj;

- (BOOL)isWebScriptObjectArray:(id)possibleScriptObj;
- (BOOL)isWebScriptObjectDate:(id)possibleDate;
- (BOOL)isWebScriptObjectBase64:(id)possibleBase64;
- (BOOL)isWebScriptObjectBase64Encode:(id)possibleBase64Encode;
- (BOOL)isWebScriptObject:(id)possibleObject;

- (NSMutableArray *)arrayForWebScriptObject:(WebScriptObject *)scriptObj;
- (void)findAllJsPropertyKeysFromParamString:(NSString *)paramString;

- (NSString *)trimKey:(NSString *)keyIn;
- (NSMutableString *)removeString:(NSString *)pattern fromString:(NSMutableString *)result;
@end


@implementation ParamParser

- (id)init {
	self = [super init];
	if (self) {
		[self setupWebView];
	}
	return self;
}

- (void)dealloc {
	[webView release];
	[super dealloc];	
}

#pragma mark -
#pragma mark Other methods

- (void)setupWebView {
	if (webView) [webView release];
	webView = [[WebView alloc] initWithFrame:NSMakeRect(1, 1, 1, 1) frameName:@"params" groupName:@"params"];
	[webView setFrameLoadDelegate:self];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"params" ofType:@"html"];
	NSURL *fURL = [NSURL fileURLWithPath:path];
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:fURL]];
}

- (NSArray *)arrayWithParamString:(NSString *)paramString {
	NSArray *result = nil;
	@try {
		id win = [webView windowScriptObject];
		[win callWebScriptMethod:@"doEval" withArguments:[NSArray arrayWithObject:paramString]];
		
		if ([self javaScriptEvalErrorOcurred]) {
			[NSException raise:@"ParamEvalException" format:@"%@",[[self params] webScriptValueAtIndex:0]];
		}
		
		[self findAllJsPropertyKeysFromParamString:paramString];
		result = [self processParamItem:[self params]];
	} @catch (NSException *e) {
		NSLog(@"catch :%@",[e reason]);
		[self setupWebView];
		[e raise];
	}
	return result;
}

- (BOOL)javaScriptEvalErrorOcurred {
	id paramsObj = [self params];
	return [paramsObj isKindOfClass:[WebScriptObject class]]
		&& [[paramsObj webScriptValueAtIndex:0] isKindOfClass:[NSString class]]
		&& [[paramsObj webScriptValueAtIndex:0] hasPrefix:@"Param Eval Error:"];
}

#pragma mark -
#pragma mark - methods for converting 'Array' WebScriptObjects to NSArrays

- (id)processParamItem:(id)item {
	if ([self isWebScriptObjectArray:item]) {
		return [self convertToArray:item];
	} else if ([self isWebScriptObjectDate:item]){
		return [self convertToDate:item];
	} else if ([self isWebScriptObjectBase64:item]){
		return [self convertToBase64:item];
	} else if ([self isWebScriptObjectBase64Encode:item]){
		return [self convertToBase64Encode:item];
	} else if ([self isWebScriptObject:item]){
		return [self convertToDictionary:item];
	} else {
		return item;
	}
}

- (NSArray *)convertToArray:(WebScriptObject *)obj {
	NSMutableArray *result = [self arrayForWebScriptObject:obj];
	
	int total = [result count];
	id elem;
	int i = 0;
	for ( ; i < total; i++) {
		elem = [result objectAtIndex:i];
		[result replaceObjectAtIndex:i withObject:[self processParamItem:elem]];
	}

	return result;
}

- (NSDate *)convertToDate:(WebScriptObject *)obj {
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	
	[comps setSecond:[[obj callWebScriptMethod:@"getSeconds"  withArguments:nil] intValue]];
	[comps setMinute:[[obj callWebScriptMethod:@"getMinutes"  withArguments:nil] intValue]];
	[comps setHour  :[[obj callWebScriptMethod:@"getHours"    withArguments:nil] intValue]];
	[comps setDay   :[[obj callWebScriptMethod:@"getDate"	  withArguments:nil] intValue]];
	[comps setMonth :[[obj callWebScriptMethod:@"getMonth"	  withArguments:nil] intValue] + 1];
	[comps setYear  :[[obj callWebScriptMethod:@"getFullYear" withArguments:nil] intValue]];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDate *result = [gregorian dateFromComponents:comps];
	NSLog(@"Date : %@",result);
	return result;
}

- (NSData *)convertToBase64:(WebScriptObject *)obj {
	NSString *dataString = (NSString *)[obj valueForKey:@"dataString"];
	return [NSData dataWithBase64EncodedString:dataString];
}

- (NSData *)convertToBase64Encode:(WebScriptObject *)obj {
	NSString *dataString = (NSString *)[obj valueForKey:@"dataString"];
	return [dataString dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSDictionary *)convertToDictionary:(WebScriptObject *)obj {
	NSMutableDictionary *result = [NSMutableDictionary dictionary];

	id key = nil;
	id value = nil;
	NSEnumerator *e = [jsPropertyKeys objectEnumerator];
	while ((key = [e nextObject]) != nil) {
		value = [self processParamItem:[obj valueForKey:key]];
		if (value && [WebUndefined undefined] != value) {
			[result setObject:value forKey:key];
		}
	}
	return result;
}

- (BOOL)isWebScriptObjectArray:(id)possibleArray {
	id jsWindow = [webView windowScriptObject];
	id result = [jsWindow callWebScriptMethod:@"isArray" withArguments:[NSArray arrayWithObject:possibleArray]];
	return [[result valueForKey:@"value"] intValue] == 1;
}

- (BOOL)isWebScriptObjectDate:(id)possibleDate {
	id jsWindow = [webView windowScriptObject];
	id result = [jsWindow callWebScriptMethod:@"isDate" withArguments:[NSArray arrayWithObject:possibleDate]];
	return [[result valueForKey:@"value"] intValue] == 1;
}

- (BOOL)isWebScriptObjectBase64:(id)possibleBase64 {
	id jsWindow = [webView windowScriptObject];
	id result = [jsWindow callWebScriptMethod:@"isBase64" withArguments:[NSArray arrayWithObject:possibleBase64]];
	return [[result valueForKey:@"value"] intValue] == 1;
}

- (BOOL)isWebScriptObjectBase64Encode:(id)possibleBase64Encode {
	id jsWindow = [webView windowScriptObject];
	id result = [jsWindow callWebScriptMethod:@"isBase64Encode" withArguments:[NSArray arrayWithObject:possibleBase64Encode]];
	return [[result valueForKey:@"value"] intValue] == 1;
}

- (BOOL)isWebScriptObject:(id)possibleScriptObj {
	return [possibleScriptObj isKindOfClass:[WebScriptObject class]];
}

- (NSMutableArray *)arrayForWebScriptObject:(WebScriptObject *)scriptObj {
	NSMutableArray *result = [NSMutableArray array];

	id elem = nil;
	int i = 0;
	WebUndefined *undefined = [WebUndefined undefined];
	while ((elem = [scriptObj webScriptValueAtIndex:i++]) != undefined) {
		[result addObject:elem];
	}

	return result;
}

- (void)findAllJsPropertyKeysFromParamString:(NSString *)paramString {
	jsPropertyKeys = [NSMutableArray array];
	NSScanner *scanner = [NSScanner scannerWithString:paramString];
	
	NSString *currKey = @"";
	while (![scanner isAtEnd]) {
		[scanner scanUpToString:@":" intoString:&currKey];
		currKey = [self trimKey:currKey];
		[jsPropertyKeys addObject:currKey];
		[scanner scanString:@":" intoString:NULL];
	}
	if ([jsPropertyKeys count] > 0) {
		[jsPropertyKeys removeLastObject];
	}
}

- (NSString *)trimKey:(NSString *)keyIn {
	NSMutableString *result = [NSMutableString stringWithString:keyIn];

	result = [self removeString:@" " fromString:result];
	result = [self removeString:@"\r" fromString:result];
	result = [self removeString:@"\n" fromString:result];
	
	int i = [result length] - 1;
	for ( ; i > -1; i--) {
		unichar c = [result characterAtIndex:i];
		if (' ' == c || ',' == c || '{' == c) {
			return [result substringFromIndex:i+1];
		}
	}
	return result;
}

- (NSMutableString *)removeString:(NSString *)pattern fromString:(NSMutableString *)result {
	[result replaceOccurrencesOfString:pattern
							withString:@""
							   options:NSCaseInsensitiveSearch
								 range:NSMakeRange(0,[result length])];
	return result;
}

#pragma mark -
#pragma mark methods exposed to JavaScript

- (void)setParams:(id)newParams {
	if (params != newParams) {
		[params autorelease];
		params = [newParams retain];
	}
}

- (id)params {
	return params;
}

#pragma mark -
#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView *)sender windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject {
	[windowScriptObject setValue:self forKey:@"ParamParser"];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	frameLoaded = YES;
}

#pragma mark -
#pragma mark WebScripting

+ (NSString *)webScriptNameForSelector:(SEL)sel {
	NSString *name = nil;
    if (sel == @selector(setParams:)) {
		name = @"setParams";
	}
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector {
	return aSelector != @selector(setParams:);
}

@end
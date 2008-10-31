//
//  RancheroXMLRPCServiceImpl.m
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/7/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import "RancheroXMLRPCServiceImpl.h"
#import "CURLHandle.h"

@interface RancheroXMLRPCServiceImpl (Private)
- (void)initParamParser;
@end

@implementation RancheroXMLRPCServiceImpl

+ (void)initialize {
	[CURLHandle curlHelloSignature:@"XxXx" acceptAll:YES];
}

- (id)init {
	return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)d {
	self = [super init];
	[self setDelegate:d];
	[self initParamParser];
	return self;
}

- (void)dealloc {
	[delegate release];
	[URLString release];
	[paramParser release];
	[super dealloc];
}

#pragma mark -
#pragma mark XMLRPCService

- (void)executeAsync:(NSString *)method withParamString:(NSString *)paramString {
	//NSLog(@"executing URL:%@, method:%@, params:%@",[self URLString],method,paramString);
	rpcCall = [[XMLRPCCall alloc] initWithURLString:[self URLString]];
	[rpcCall setMethodName:method];
	
	NSArray *params = nil;
	@try {
		params = [paramParser arrayWithParamString:paramString];
	} @catch (NSException *e) {
		[delegate paramEvalExceptionOcurred:e];
		return;
	}
	//NSLog(@"param parser returned: %@",params);
	//NSArray *params = [NSArray arrayWithObject:[NSNumber numberWithInt:4]];
	
	[rpcCall setParameters:params];
	
	[startDate release];
	startDate = [[NSDate alloc] init];

	[rpcCall invokeInNewThread:self callbackSelector:@selector(rpcCallback:)];
}


#pragma mark -
#pragma mark Other

- (void)initParamParser {
	paramParser = [[ParamParser alloc] init];
}

- (void)rpcCallback:(id)sender {	
	double duration = [startDate timeIntervalSinceNow];
	
	NSString *codeSource     = @"";
	id returnedObject		 = [rpcCall returnedObject];
	if (returnedObject) {
		codeSource			 = [returnedObject description];
	}
		
	[delegate rpcCallbackWithRequestXMLString:[rpcCall requestText]
							responseXMLString:[rpcCall responseText]
						 responseObjectString:codeSource
									 duration:duration];
}

#pragma mark -
#pragma mark Accessors

- (id)delegate {
	return delegate;
}

- (void)setDelegate:(id)d {
	[delegate release];
	delegate = [d retain];
}

- (NSString *)URLString {
	return URLString;
}

- (void)setURLString:(NSString *)s {
	if (URLString != s) {
		[URLString autorelease];
		URLString = [s retain];
	}
}

@end

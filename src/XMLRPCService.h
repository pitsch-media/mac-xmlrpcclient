//
//  XMLRPCService.h
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/7/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMLRPCDelegate;

@protocol XMLRPCService <NSObject>
- (id)initWithDelegate:(id)d;
- (void)executeAsync:(NSString *)method withParamString:(NSString *)paramString;
- (id)delegate;
- (void)setDelegate:(id)d;
- (NSString *)URLString;
- (void)setURLString:(NSString *)s;	
@end

@interface NSObject (XMLRPCDelegate)
- (void)rpcCallbackWithRequestXMLString:(NSString *)requestXML
					  responseXMLString:(NSString *)responseXML
				   responseObjectString:(NSString *)responseObjectString
							   duration:(double)duration;
- (void)paramEvalExceptionOcurred:(NSException *)e;
@end

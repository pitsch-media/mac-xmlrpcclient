//
//  RancheroXMLRPCServiceImpl.h
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/7/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLRPCService.h"
#import "XMLRPCCall.h"
#import "ParamParser.h"

@interface RancheroXMLRPCServiceImpl : NSObject <XMLRPCService> {
	id delegate;
	NSString *URLString;
	XMLRPCCall *rpcCall;
	ParamParser *paramParser;
	NSDate *startDate;
}

@end

//
//  FaultChecker.h
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/25/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FaultChecker : NSObject {
	int tagCount;
	BOOL finishedParsing;
	BOOL containsFault;
}

- (BOOL)XMLRPCResponseStringContainsFault:(NSString *)response;
@end

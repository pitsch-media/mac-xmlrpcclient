//
//  XMLRPCUtils.h
//  XML-RPC Client
//
//  Created by Todd Ditchendorf on 10/8/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface ParamParser : NSObject {
	WebView *webView;
	NSArray *params;
	NSMutableArray *jsPropertyKeys;
	BOOL frameLoaded;
}

- (NSArray *)arrayWithParamString:(NSString *)paramString;
- (id)params;
- (void)setParams:(id)params;
@end

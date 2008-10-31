#import "BorderView.h"

@implementation BorderView

- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect]) != nil) {
		topColor = [[NSColor colorWithDeviceRed:.557 green:.557 blue:.557 alpha:1.0] retain];
		botColor = [[NSColor colorWithDeviceRed:.745 green:.745 blue:.745 alpha:1.0] retain];
		sidColor = [[NSColor colorWithDeviceRed:.639 green:.639 blue:.639 alpha:1.0] retain];
	}
	return self;
}

- (void)dealloc {
	[topColor release];
	[botColor release];
	[sidColor release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];

	// draw top line
	[topColor set];
	NSPoint topA = NSMakePoint(rect.origin.x, NSMaxY(rect));
	NSPoint topB = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
	NSBezierPath *topPath = [NSBezierPath bezierPath];
	[topPath setLineWidth:2.0];
	[topPath moveToPoint:topA];
	[topPath lineToPoint:topB];
	[topPath stroke];

	// draw right line
	[sidColor set];
	NSPoint ritA = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
	NSPoint ritB = NSMakePoint(NSMaxX(rect), rect.origin.y);
	NSBezierPath *ritPath = [NSBezierPath bezierPath];
	[ritPath setLineWidth:2.0];
	[ritPath moveToPoint:ritA];
	[ritPath lineToPoint:ritB];
	[ritPath stroke];

	// draw left line
	NSPoint lefA = NSMakePoint(rect.origin.x, NSMaxY(rect));
	NSPoint lefB = NSMakePoint(rect.origin.x, rect.origin.y);
	NSBezierPath *lefPath = [NSBezierPath bezierPath];
	[lefPath setLineWidth:2.0];
	[lefPath moveToPoint:lefA];
	[lefPath lineToPoint:lefB];
	[lefPath stroke];
	
	// draw bottom line
	[botColor set];
	NSPoint botA = rect.origin;
	NSPoint botB = NSMakePoint(NSMaxX(rect), rect.origin.y);
	NSBezierPath *botPath = [NSBezierPath bezierPath];
	[botPath setLineWidth:2.0];
	[botPath moveToPoint:botA];
	[botPath lineToPoint:botB];
	[botPath stroke];
}

@end
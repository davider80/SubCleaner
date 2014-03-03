#import <Cocoa/Cocoa.h>

@interface NSBezierPath(CocoaDevCategory)
+ (NSBezierPath *)bezierPathWithJaggedOvalInRect:(NSRect)r spacing:(float)spacing;
+ (NSBezierPath *)bezierPathWithJaggedPillInRect:(NSRect)r spacing:(float)spacing;
+ (NSBezierPath*)bezierPathWithRoundRectInRect:(NSRect)aRect radius:(float)radius;
+ (NSBezierPath*)bezierPathWithRoundRectInRectWithProgress:(NSRect)aRect radius:(float)radius percentage:(int)percentage;
+ (NSBezierPath *)bezierPathWithTriangleInRect:(NSRect)r edge:(NSRectEdge)edge;
@end
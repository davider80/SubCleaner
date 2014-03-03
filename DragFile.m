#import "DragFile.h"
#import "AppController.h"

@implementation DragFile


- (void)drawRect:(NSRect)rect
{
    NSRect ourBounds = [self bounds];
    [super drawRect:rect];
	
	NSColor *bgGrey; 	
	NSColor *fgGrey;
	
	if(!highlighted) {
		bgGrey = [NSColor colorWithCalibratedWhite: 0.6 alpha: 1.0];
		fgGrey = [NSColor colorWithCalibratedWhite: 0.93 alpha: 1.0];
	}
	else {
		fgGrey = [NSColor colorWithCalibratedWhite: 0.6 alpha: 1.0];
		bgGrey = [NSColor colorWithCalibratedWhite: 0.93 alpha: 1.0];		
	}

	[fgGrey set];
	[NSBezierPath fillRect:ourBounds];
	
	//[fgGrey set];
    //[[NSBezierPath bezierPathWithRoundRectInRect:NSMakeRect(10,20,30,40) radius:50] stroke];
	if(!highlighted)	
		[[NSColor colorWithCalibratedWhite: 0.6 alpha: 1.0] set];
	else 
		[[NSColor colorWithCalibratedWhite: 0.93 alpha: 1.0] set];

	NSRect squareBounds =  NSMakeRect(ourBounds.origin.x + ourBounds.size.width/2 - ourBounds.size.height/4 , ourBounds.origin.y + (ourBounds.size.height/4), ourBounds.size.height/2, ourBounds.size.height/2);

	//NSBezierPath *bezierPath = [NSBezierPath bezierPathWithJaggedOvalInRect: squareBounds spacing: 20];
	//NSBezierPath *bezierPath = [NSBezierPath bezierPathWithJaggedPillInRect: squareBounds spacing: 20];
	NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundRectInRect: squareBounds radius: 20];
	[bezierPath setLineWidth:4.0];	
	[bezierPath stroke];
	
	NSRect triangleBounds = NSMakeRect(squareBounds.origin.x+20, squareBounds.origin.y+20, squareBounds.size.width-40, 30);
	NSRect rectBounds = NSMakeRect(squareBounds.origin.x+40, squareBounds.origin.y+49, squareBounds.size.width-80, 30);
	[[NSBezierPath bezierPathWithTriangleInRect: triangleBounds edge:NSMaxYEdge] fill];
	[NSBezierPath fillRect:rectBounds];
	
	if(!highlighted)
	{
		[@"Drop Subtitles Here" drawInRect:NSMakeRect(75,ourBounds.size.height-50,ourBounds.size.width-10,40) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Lucida Grande Bold" size:18], NSFontAttributeName,
		[[NSColor colorWithCalibratedWhite: 0.6 alpha: 1.0] highlightWithLevel:0.0], NSForegroundColorAttributeName,
		nil, nil]];
	}
	else
	{
		[@"Drop Subtitles Here" drawInRect:NSMakeRect(75,ourBounds.size.height-50,ourBounds.size.width-10,40) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont fontWithName:@"Lucida Grande Bold" size:18], NSFontAttributeName,
			[[NSColor colorWithCalibratedWhite: 0.93 alpha: 1.0] highlightWithLevel:0.0], NSForegroundColorAttributeName,
			nil, nil]];
	}
	
	if(state == 1)
	{
			NSBezierPath* thePath = [NSBezierPath bezierPath];
			
			[thePath moveToPoint:NSMakePoint((ourBounds.size.width/2)-10, 34)];
			[thePath lineToPoint:NSMakePoint((ourBounds.size.width/2)+10, 14)];
			[thePath moveToPoint:NSMakePoint((ourBounds.size.width/2)-10, 14)];
			[thePath lineToPoint:NSMakePoint((ourBounds.size.width/2)+10, 34)];
			[thePath setLineWidth:8.0];	
			[thePath stroke];	
	}
	else if(state == 2)
	{
		NSBezierPath* thePath = [NSBezierPath bezierPath];
		
		[thePath moveToPoint:NSMakePoint((ourBounds.size.width/2)-10, 25)];
		[thePath lineToPoint:NSMakePoint((ourBounds.size.width/2)-3, 15)];
		[thePath lineToPoint:NSMakePoint((ourBounds.size.width/2)+10, 35)];
		[thePath setLineWidth:8.0];	
		[thePath stroke];	
	}
	else if(state == 3)
	{
		//NSRect squareBounds =  NSMakeRect(ourBounds.origin.x + ourBounds.size.width/2 - ourBounds.size.height/4 , ourBounds.origin.y + (ourBounds.size.height/4), ourBounds.size.height/2, ourBounds.size.height/2);
		NSBezierPath *bezierPath1 = [NSBezierPath bezierPathWithRoundRectInRect: NSMakeRect((ourBounds.size.width/2)-75, 18, 150, 15) radius: 20];	
		[bezierPath1 setLineWidth:2.0];	
		[bezierPath1 stroke];
	
		NSLog(@"Percentage %d", progress);
		
		NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundRectInRectWithProgress: NSMakeRect((ourBounds.size.width/2)-75, 18, 150, 15) radius: 20 percentage:progress];		
		[bezierPath setLineWidth:2.0];	
		[bezierPath fill];
	}
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) 
	{
		highlighted = YES;
		[self setNeedsDisplay:YES];		
		return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    //we aren't particularily interested in this so we will do nothing
    //this is one of the methods that we do not have to implement
	highlighted = NO;
	[self setNeedsDisplay:YES];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
        if (sourceDragMask & NSDragOperationLink) {
           // [self addLinkToFiles:files];
			[self setSubtitleFilenames:files];
			[[NSApp delegate] fileDragged:self];
        }
    }	
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    highlighted = NO;
    [self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
	[self registerForDraggedTypes:
		[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    return self;
}


- (void)dealloc
{
    [self unregisterDraggedTypes];
	[subtitlesFilenames release];
    [super dealloc];
}

- (void)setSubtitleFilenames:(NSArray *)filenames
{
	[filenames retain];
	[subtitlesFilenames release];
	subtitlesFilenames = filenames;
}

- (NSArray *)subtitlesFilenames
{
	return subtitlesFilenames;
}

- (void)setState:(int)stateResult
{
	state = stateResult;
	[self displayRect:[self bounds]];
}

- (void)setProgress:(int)value
{
	progress = value;
	[self displayRect:[self bounds]];
}


@end

/* DragFile */

#import <Cocoa/Cocoa.h>
#import "Bezier.h"

@interface DragFile : NSView
{
	BOOL highlighted;
	NSArray *subtitlesFilenames;
	int state;
	int progress;
}

- (void)setSubtitleFilenames:(NSArray *)filenames;
- (NSArray *)subtitlesFilenames;
- (void)setState:(int)stateResult;
- (void)setProgress:(int)value;

@end

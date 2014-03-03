//
//  Subtitle.h
//  Subtitle ICU
//
//  Created by Davide Rivola on 08.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SubtitleItem : NSObject {
	long timeShowText;
	long timeHideText;
	NSMutableArray *lines;
}

- (long)timeShowText;
- (void)setTimeShowText:(long)time;
- (long)timeHideText;
- (void)setTimeHideText:(long)time;
- (NSMutableArray *)lines;

- (NSString *)generateOutputLine:(int)lineNumber;
- (void)addLine:(NSString *)lineToAdd;
- (BOOL)removeAccents;
- (BOOL)removeStyleTags;
- (BOOL)deleteStringsBetween;
- (BOOL)addStringAtEnd:(NSString *)stringToAdd;
- (BOOL)wrapLinesAtLength:(int)maxCharsPerLine withMaxLines:(int)maxLines;
- (BOOL)putSubtitleToOneLine;
- (int)linesNo;
- (int)charsNo;

@end

//
//  Subtitle.h
//  SubCleaner
//
//  Created by Davide Rivola on 22.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubtitleItem.h"

@interface Subtitle : NSObject {
	NSMutableArray *subtitleArray;
	NSStringEncoding stringEncoding;
	NSString *readString;
}

- (int)loadFromFile:(NSString *)fileName;
- (BOOL)saveToFile:(NSString *)fileName;

- (BOOL)importSubRip;
- (BOOL)importSubViewer;
- (BOOL)importMicroDVD:(double)framerate;
- (BOOL)importSingleLineTMPlayer;
- (BOOL)importMultiLineTMPlayer;
- (BOOL)importMPL2;

- (BOOL)removeAccents;
- (BOOL)removeStyleTags;
- (BOOL)deleteStringsBetween;
- (BOOL)addStringAtEnd:(NSString *)stringToAdd;
- (BOOL)wrapLines:(int)maxCharsPerLine withMaxLines:(int)maxLines;

- (BOOL)splitSubtitleItem:(int)index atLine:(int)line;
- (int)checkFormat:(NSString *)stringToCheck;



@end

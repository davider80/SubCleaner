//
//  Subtitle.m
//  Subtitle ICU
//
//  Created by Davide Rivola on 08.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SubtitleItem.h"


@implementation SubtitleItem

- (id)init
{
	[super init];
	[self setTimeShowText:0];
	[self setTimeHideText:0];
	lines = [NSMutableArray arrayWithCapacity:0]; 
	return self;
}

- (long)timeShowText
{
	return timeShowText;
}

- (void)setTimeShowText:(long)time
{
	timeShowText = time;
}

- (long)timeHideText
{
	return timeHideText;
}

- (void)setTimeHideText:(long)time
{
	timeHideText = time;
}

- (NSMutableArray *)lines
{
	return lines;
}

- (NSString *)description
{
	NSString *result;
	result = [[NSString alloc] initWithFormat: @"%d -> %d: %@", timeShowText, timeHideText, [lines objectAtIndex:0]]; 
	return result;
}

- (NSString *)generateOutputLine:(int)lineNumber
{	
	NSString *result, *start, *stop;
	long hour, min, sec, dec; 
	int i;
	
	hour = timeShowText / (3600*1000);
	min = (timeShowText - hour*3600*1000) / (60*1000);
	sec = (timeShowText - hour*3600*1000 - min*60*1000)/1000;
	dec = timeShowText - hour*3600*1000 - min*60*1000 - sec*1000;
	start = [[NSString alloc] initWithFormat: @"%02u:%02u:%02u,%03u", hour, min, sec, dec];

	hour = timeHideText / (3600*1000);
	min = (timeHideText - hour*3600*1000) / (60*1000);
	sec = (timeHideText - hour*3600*1000 - min*60*1000)/1000;
	dec = timeHideText - hour*3600*1000 - min*60*1000 - sec*1000;
	stop = [[NSString alloc] initWithFormat: @"%02u:%02u:%02u,%03u", hour, min, sec, dec];

	result = [[NSString alloc] initWithFormat: @"%d\r\n%@ --> %@\r\n", lineNumber, start, stop];
	
	for(i=0; i<[lines count]; i++)
	{
		result = [result stringByAppendingString:[lines objectAtIndex:i]];
		result = [result stringByAppendingString:@"\r\n"];			
	}
	result = [result stringByAppendingString:@"\r\n"];	
	
	[start release];
	[stop release];
	return result;
}

- (void)addLine:(NSString *)lineToAdd
{
	[lines addObject:lineToAdd];
}

- (BOOL)removeAccents
{
	int i=0;	
	while(i<[lines count])
	{
		[lines replaceObjectAtIndex:i withObject:[[[NSString alloc] initWithData:[[lines objectAtIndex:i]  
																				  dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]  
																		encoding:NSASCIIStringEncoding] autorelease]];
		 i++;
	}

	return YES;
}

- (BOOL)removeStyleTags
{
	
	int i=0;
	NSString * stringToCheck;
	NSString *stringToWrite = NULL;
	
	NSScanner *theScanner;
	NSCharacterSet *styleSet = [NSCharacterSet characterSetWithCharactersInString:@"<\\>"];
	int lastLocation;
	
	while(i<[lines count])
	{
		stringToCheck = [lines objectAtIndex:i];
		stringToWrite = NULL;
	
		theScanner = [NSScanner scannerWithString:stringToCheck];
		lastLocation = 0;
		
		while ([theScanner isAtEnd] == NO) 
		{
			if([theScanner scanCharactersFromSet:styleSet intoString:nil] &&
			   [theScanner scanUpToCharactersFromSet:styleSet intoString:nil] &&
			   [theScanner scanCharactersFromSet:styleSet intoString:nil])
			{
				if(([theScanner scanLocation] - lastLocation) <=3)
					lastLocation = [theScanner scanLocation];
			}
			else
				//Maybe the line start with a space
			{
				[theScanner scanUpToCharactersFromSet:styleSet intoString:nil];
				if(stringToWrite)
					stringToWrite = [stringToWrite stringByAppendingString:[stringToCheck substringWithRange:NSMakeRange(lastLocation,[theScanner scanLocation]-lastLocation)]];
				else
					stringToWrite = [stringToCheck substringWithRange:NSMakeRange(lastLocation,[theScanner scanLocation]-lastLocation)];
				
				lastLocation = [theScanner scanLocation];
			}
		}	

		if ( stringToWrite != nil)
			[lines replaceObjectAtIndex:i withObject:stringToWrite];
		
		i++;
	}
	
	return YES;
}

- (BOOL)deleteStringsBetween
{	
	int i=0;
	NSString * stringToCheck;
	NSString *stringToWrite = NULL;
	
	NSScanner *theScanner;
	NSCharacterSet *styleSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
	int lastLocation;
	
	while(i<[lines count])
	{
		stringToCheck = [lines objectAtIndex:i];
		stringToWrite = NULL;
		
		theScanner = [NSScanner scannerWithString:stringToCheck];
		lastLocation = 0;
		
		while ([theScanner isAtEnd] == NO) 
		{
			if([theScanner scanCharactersFromSet:styleSet intoString:nil] &&
			   [theScanner scanUpToCharactersFromSet:styleSet intoString:nil] &&
			   [theScanner scanCharactersFromSet:styleSet intoString:nil])
			{
				lastLocation = [theScanner scanLocation];
			}
			else
				//Maybe the line start with a space
			{
				[theScanner scanUpToCharactersFromSet:styleSet intoString:nil];
				if(stringToWrite)
					stringToWrite = [stringToWrite stringByAppendingString:[stringToCheck substringWithRange:NSMakeRange(lastLocation,[theScanner scanLocation]-lastLocation)]];
				else
					stringToWrite = [stringToCheck substringWithRange:NSMakeRange(lastLocation,[theScanner scanLocation]-lastLocation)];
				
				lastLocation = [theScanner scanLocation];
			}
		}	
		
		if ( stringToWrite != nil)
			[lines replaceObjectAtIndex:i withObject:stringToWrite];
		
		i++;
	}
	
	return YES;
}

- (BOOL)addStringAtEnd:(NSString *)stringToAdd
{
	int i=0;	
	while(i<[lines count])
	{
		[lines replaceObjectAtIndex:i withObject:[[lines objectAtIndex:i] stringByAppendingString:stringToAdd]];
		i++;
	}
	
	return YES;
}

- (BOOL)wrapLinesAtLength:(int)maxCharsPerLine withMaxLines:(int)maxLines
{
	int i=0;
	NSString * stringToCheck;
	
	NSScanner *theScanner;
	NSCharacterSet *spaceSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
	int lastLocation, charNo;
	
	if((maxCharsPerLine<0) && (maxLines>0))
	{
		if([self linesNo] <= maxLines)
			return YES;
		else
			charNo = [self charsNo]/maxLines;
	}
	else 
	{
		charNo = maxCharsPerLine;
	}

	if((maxLines>0) && (maxCharsPerLine<0))
		[self putSubtitleToOneLine];

	while(i<[lines count])
	{
		stringToCheck = [lines objectAtIndex:i];
		
		if([stringToCheck length] > charNo)
		{
			theScanner = [NSScanner scannerWithString:stringToCheck];
			[theScanner setCharactersToBeSkipped:nil];
			
			lastLocation = 0;
			
			while ([theScanner isAtEnd] == NO) 
			{
				if([theScanner scanUpToCharactersFromSet:spaceSet intoString:NULL])
				{
					[theScanner scanCharactersFromSet:spaceSet intoString:nil];
					
					if([theScanner scanLocation] > charNo)
					{
						if(lastLocation)
						{
							[lines replaceObjectAtIndex:i withObject:[stringToCheck substringFromIndex:lastLocation]];
							[lines insertObject:[stringToCheck substringToIndex:lastLocation] atIndex:i];
						}
						break;
					}
					
					lastLocation = [theScanner scanLocation];
				}
				else
					//Maybe the line start with a space
				{
					NSLog(@"Subtitle: line that begin with a space [%d] %@",i+1,stringToCheck);
					[theScanner scanCharactersFromSet:spaceSet intoString:nil];
				}
			}	
		}
		i++;
	}
	
	return YES;
}

- (BOOL)putSubtitleToOneLine
{
	int i;
	NSString *text = nil;
	
	for(i=0; i<[lines count];i++)
	{
		if(text)
		{
			text = [text stringByAppendingString:@" "];
			text = [text stringByAppendingString:[lines objectAtIndex:i]];
		}
		else
			text = [lines objectAtIndex:i];		
	}
	
	[lines removeAllObjects];
	[lines addObject:text];	
	return YES;	
}

- (int)linesNo
{
	return [lines count];
}

- (int)charsNo
{
	int i,n=0;
	
	
	for(i=0; i<[lines count];i++)
	{
		n += [[lines objectAtIndex:i] length];
	}
	
	return n;
}

- (void)dealloc
{
	[super dealloc];
}

@end

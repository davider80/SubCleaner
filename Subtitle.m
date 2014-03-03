#import "Subtitle.h"

@implementation Subtitle

- (id)init
{	
	[super init];
	subtitleArray = [NSMutableArray new];
	return self;
}

- (void)dealloc	
{
	[subtitleArray release];
	[super dealloc];
}


- (int)loadFromFile:(NSString *)fileName
{
	NSLog(@"Subtitle: loading file %@",fileName);
	NSError *error;
	readString = [NSString stringWithContentsOfFile:fileName usedEncoding:&stringEncoding error:&error];
	
	[subtitleArray removeAllObjects];
	
	if(readString == nil)
	{
		//Let's try with UTF8
		readString = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&error];	

		if(readString == nil)
		{
			//Let's try with Windows Latin 1
			readString = [NSString stringWithContentsOfFile:fileName encoding:NSWindowsCP1252StringEncoding error:&error];	
			
			
			if(readString == nil)
			{
				//Let's try with Windows Latin 1
				readString = [NSString stringWithContentsOfFile:fileName encoding:NSMacOSRomanStringEncoding error:&error];	
			
				if(readString == nil)
				{
					NSAlert *alert = [NSAlert alertWithError:error];
					[alert runModal];
					return 0;
				}
				
				else
				{
					stringEncoding = NSMacOSRomanStringEncoding;
					NSLog(@"Subtitle: encoding is Mac OS Roman");
				}
			}
			else
			{
				stringEncoding = NSWindowsCP1252StringEncoding;
				NSLog(@"Subtitle: encoding is Window Latin 1");
			}
		}
		else
		{
			stringEncoding = NSUTF8StringEncoding;
			NSLog(@"Subtitle: encoding is UTF8");
		}
	}
	else
	{
			NSLog(@"Subtitle: encoding auto detected");
	}
	
	return [self checkFormat:readString];
}

- (BOOL)saveToFile:(NSString *)fileName
{
	int i=0;
	NSMutableString *stringToWrite = [NSMutableString new];	
	for(i; i<[subtitleArray count];i++){
		[stringToWrite appendString:[[subtitleArray objectAtIndex:i] generateOutputLine:(i+1)]];
	}
	[stringToWrite writeToFile:fileName atomically:YES encoding:stringEncoding error:NULL];
	[stringToWrite release];
	return YES;
}	

- (BOOL)importSubRip
{
	int a1,a2,a3,a4,b1,b2,b3,b4;
	NSArray *lines = [readString componentsSeparatedByString:@"\n"];

	//if the lines count is 1 this file it's a classic mac text file, let's try again
	if([lines count] < 2)
	lines = [readString componentsSeparatedByString:@"\r"];	


	NSCharacterSet *decimalSep = [NSCharacterSet characterSetWithCharactersInString:@"\\.,"];
	SubtitleItem *subItem = NULL;
	int i,j, lastSubItem, lastScanLocation;
	int curSubItem = -1;
	long subStart, subEnd;

	for(i=0; i<[lines count]; i++)
	{
		BOOL lastLine = (i+1 == [lines count]);
		
		NSScanner *scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];
		if (([scanner scanInt:&a1] &&
			 [scanner scanString:@":" intoString:nil] &&
			 [scanner scanInt:&a2] &&
			 [scanner scanString:@":" intoString:nil] &&
			 [scanner scanInt:&a3] &&
			 [scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			 [scanner scanInt:&a4] &&
			 [scanner scanString:@"-->" intoString:nil] &&
			 [scanner scanInt:&b1] &&
			 [scanner scanString:@":" intoString:nil] &&
			 [scanner scanInt:&b2] &&
			 [scanner scanString:@":" intoString:nil] &&
			 [scanner scanInt:&b3] &&
			 [scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			 [scanner scanInt:&b4]) || lastLine)
		{	
			//It's a timestamp line
			lastSubItem = curSubItem;
			
			if(lastLine)
				curSubItem = i+1;
			else
				curSubItem = i;
			
			if(lastSubItem != -1)
			{
				//Add last sub
				subItem = [SubtitleItem new];
				[subItem setTimeShowText:subStart];
				[subItem setTimeHideText:subEnd];
				
				for(j=lastSubItem; j<curSubItem; j++)
				{
					NSString *stringToAdd;
					
					if(j!=lastSubItem)
					{
						stringToAdd = [[lines objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
						
						//is empty?
						if(![[stringToAdd stringByTrimmingCharactersInSet:[NSCharacterSet 
							whitespaceCharacterSet]] length])
							continue;
						
						//Is the last and it's a number?
						if(j+1 == curSubItem)
						{
							NSScanner *scannerLastLine = [NSScanner scannerWithString:stringToAdd];
							if ([scannerLastLine scanInt:nil])
								continue;
						}
						
						[subItem addLine:stringToAdd];
					}
					else
					{
						stringToAdd = [[lines objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
						
						//Let's check if we have an error of type 3
						if(lastScanLocation < [stringToAdd length])
						{
							//is empty?
							if(![[[stringToAdd substringFromIndex:lastScanLocation] stringByTrimmingCharactersInSet:[NSCharacterSet 
								whitespaceCharacterSet]] length])
								continue;	
							
							[subItem addLine:[stringToAdd substringFromIndex:lastScanLocation]];
						}
					}
				}
				
				[subtitleArray addObject:subItem];
				[subItem release];
			}
			
			//before to store the new timing let's check if we have a error of type 2
			while(a1>99)
				a1 -= (a1/100)*100;
			
			//Store new sub timing
			subStart = a1*3600*1000+a2*60*1000+a3*1000+a4;
			subEnd = b1*3600*1000+b2*60*1000+b3*1000+b4;
			lastScanLocation = [scanner scanLocation];
		}
	}
	return YES;
}

- (BOOL)importSubViewer
{	
	int a1,a2,a3,a4,b1,b2,b3,b4;
	NSArray *lines = [readString componentsSeparatedByString:@"\n"];
	
	//if the lines count is 1 this file it's a classic mac text file, let's try again
	if([lines count] < 2)
		lines = [readString componentsSeparatedByString:@"\r"];	
	
	
	NSCharacterSet *decimalSep = [NSCharacterSet characterSetWithCharactersInString:@"\\.,"];
	SubtitleItem *subItem = NULL;
	int i,j,w, lastSubItem, lastScanLocation;
	int curSubItem = -1;
	long subStart, subEnd;
	
	for(i=0; i<[lines count]; i++)
	{
		BOOL lastLine = (i+1 == [lines count]);
		
		NSScanner *scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];
		if (([scanner scanInt:&a1] &&
			 [scanner scanString:@":" intoString:nil] &&
			 [scanner scanInt:&a2] &&
			 [scanner scanString:@":" intoString:nil] &&
			 [scanner scanInt:&a3] &&
			 [scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			 [scanner scanInt:&a4] &&
			 [scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			 [scanner scanInt:&b1] &&
			 [scanner scanString:@":" intoString:nil] &&
			 [scanner scanInt:&b2] &&
			 [scanner scanString:@":" intoString:nil] &&
			 [scanner scanInt:&b3] &&
			 [scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			 [scanner scanInt:&b4]) || lastLine)
		{	
			//It's a timestamp line
			lastSubItem = curSubItem;
			
			if(lastLine)
				curSubItem = i+1;
			else
				curSubItem = i;
			
			if(lastSubItem != -1)
			{
				//Add last sub
				subItem = [SubtitleItem new];
				[subItem setTimeShowText:subStart];
				[subItem setTimeHideText:subEnd];
				
				for(j=lastSubItem; j<curSubItem; j++)
				{
					NSString *stringToAdd;
					
					if(j!=lastSubItem)
					{
						stringToAdd = [[lines objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
						
						//is empty?
						if(![[stringToAdd stringByTrimmingCharactersInSet:[NSCharacterSet 
							whitespaceCharacterSet]] length])
							continue;
						
						if([stringToAdd rangeOfString:@"[br]"].location != NSNotFound)
						{
							NSArray *textLines = [stringToAdd componentsSeparatedByString:@"[br]"];
							
							for(w=0; w< [textLines count]; w++)
								[subItem addLine:[textLines objectAtIndex:w]];				
						}
						else
						{
							NSArray *textLines = [stringToAdd componentsSeparatedByString:@"[BR]"];
							
							for(w=0; w< [textLines count]; w++)
								[subItem addLine:[textLines objectAtIndex:w]];				
						}
					}
					else
					{
						stringToAdd = [[lines objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
						
						NSLog(@"scan %d len %d",lastScanLocation, [stringToAdd length]);
						
						//Let's check if we have an error of type 3
						if(lastScanLocation < [stringToAdd length])
						{
							NSString * stringToAddSubString = [stringToAdd substringFromIndex:lastScanLocation];
							
							//is empty?
							if(![[stringToAddSubString stringByTrimmingCharactersInSet:[NSCharacterSet 
								whitespaceCharacterSet]] length])
								continue;
							
							if([stringToAddSubString rangeOfString:@"[br]"].location != NSNotFound)
							{
								NSArray *textLines = [stringToAddSubString componentsSeparatedByString:@"[br]"];
								
								for(w=0; w< [textLines count]; w++)
									[subItem addLine:[textLines objectAtIndex:w]];				
							}
							else
							{
								NSArray *textLines = [stringToAddSubString componentsSeparatedByString:@"[BR]"];
								
								for(w=0; w< [textLines count]; w++)
									[subItem addLine:[textLines objectAtIndex:w]];				
							}
						}
					}
				}
				
				[subtitleArray addObject:subItem];
				[subItem release];
			}
			
			//Store new sub timing
			subStart = a1*3600*1000+a2*60*1000+a3*1000+a4*10;
			subEnd = b1*3600*1000+b2*60*1000+b3*1000+b4*10;
			lastScanLocation = [scanner scanLocation];
		}
	}
	return YES;
}

- (BOOL)importMicroDVD:(double)framerate
{
	NSLog(@"Framerate is %f", framerate);
	
	NSCharacterSet *microDVDSep = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
	SubtitleItem *subItem = NULL;
	int i,j,a,b;	
	
	NSArray *lines = [readString componentsSeparatedByString:@"\n"];
	
	//if the lines count is 1 this file it's a classic mac text file, let's try again
	if([lines count] < 2)
		lines = [readString componentsSeparatedByString:@"\r"];	
	
	for(i=0; i<[lines count]; i++)
	{		
		NSScanner *scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];		
		if ([scanner scanCharactersFromSet:microDVDSep intoString:nil] &&
			[scanner scanInt:&a] &&
			[scanner scanCharactersFromSet:microDVDSep intoString:nil] &&
			[scanner scanInt:&b] &&
			[scanner scanCharactersFromSet:microDVDSep intoString:nil])
		{	
			subItem = [SubtitleItem new];
		
			[subItem setTimeShowText:(1000/framerate)*a];
			[subItem setTimeHideText:(1000/framerate)*b];	
			
			NSArray *textLines = [[[lines objectAtIndex:i] substringFromIndex:[scanner scanLocation]] componentsSeparatedByString:@"|"];
				
			for(j=0; j< [textLines count]; j++)
			{
				[subItem addLine:[[textLines objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]]];	
			}
			
			[subtitleArray addObject:subItem];
			[subItem release];
		}		
	}
	return YES;
}

- (BOOL)importMPL2
{	
	NSCharacterSet *MPL2Sep = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
	SubtitleItem *subItem = NULL;
	int i,j,a,b;	
	
	NSArray *lines = [readString componentsSeparatedByString:@"\n"];
	
	//if the lines count is 1 this file it's a classic mac text file, let's try again
	if([lines count] < 2)
		lines = [readString componentsSeparatedByString:@"\r"];	
	
	for(i=0; i<[lines count]; i++)
	{		
		NSScanner *scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];		
		if ([scanner scanCharactersFromSet:MPL2Sep intoString:nil] &&
			[scanner scanInt:&a] &&
			[scanner scanCharactersFromSet:MPL2Sep intoString:nil] &&
			[scanner scanInt:&b] &&
			[scanner scanCharactersFromSet:MPL2Sep intoString:nil])
		{	
			subItem = [SubtitleItem new];
			
			[subItem setTimeShowText:a*100];
			[subItem setTimeHideText:b*100];	
			
			NSArray *textLines = [[[lines objectAtIndex:i] substringFromIndex:[scanner scanLocation]] componentsSeparatedByString:@"|"];
			
			for(j=0; j< [textLines count]; j++)
			{
				[subItem addLine:[[textLines objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" /\r"]]];	
			}
			
			[subtitleArray addObject:subItem];
			[subItem release];
		}		
	}
	return YES;
}

- (BOOL)importSingleLineTMPlayer
{	
	NSCharacterSet *TMPlayerSep = [NSCharacterSet characterSetWithCharactersInString:@":="];
	SubtitleItem *subItem = NULL;
	int i,j,a1,a2,a3;	
	
	NSArray *lines = [readString componentsSeparatedByString:@"\n"];
	
	//if the lines count is 1 this file it's a classic mac text file, let's try again
	if([lines count] < 2)
		lines = [readString componentsSeparatedByString:@"\r"];	
	
	for(i=0; i<[lines count]; i++)
	{		
		NSScanner *scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];		
		if( [scanner scanInt:&a1] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:&a2] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:&a3] &&
			[scanner scanCharactersFromSet:TMPlayerSep intoString:nil])
		{	
			if(subItem)
			{
				[subItem setTimeHideText:(a1*3600*1000+a2*60*1000+a3*1000)-10];
				
				//Add only if the lines are not empty
				if([[subItem lines] count])
					[subtitleArray addObject:subItem];
				[subItem release];			
			}
			
			subItem = [SubtitleItem new];
			[subItem setTimeShowText:(a1*3600*1000+a2*60*1000+a3*1000)];
			
			NSArray *textLines = [[[lines objectAtIndex:i] substringFromIndex:[scanner scanLocation]] componentsSeparatedByString:@"|"];
			
			for(j=0; j< [textLines count]; j++)
			{
				NSString *line = [[textLines objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
				
				if([line length])
					[subItem addLine:line];	
			}
		}	

	}
	
	//if last line add 5 seconds
	if(subItem)
	{
		[subItem setTimeHideText:(a1*3600*1000+a2*60*1000+(a3+5)*1000)];
		
		//Add only if the lines are not empty
		if([[subItem lines] count])
			[subtitleArray addObject:subItem];
		[subItem release];	
	}
	return YES;
}


- (BOOL)importMultiLineTMPlayer
{
	NSCharacterSet *TMPlayerSep = [NSCharacterSet characterSetWithCharactersInString:@",:="];
	SubtitleItem *subItem = NULL;
	int i,a1,a2,a3,l;	

	NSArray *lines = [readString componentsSeparatedByString:@"\n"];

	//if the lines count is 1 this file it's a classic mac text file, let's try again
	if([lines count] < 2)
	lines = [readString componentsSeparatedByString:@"\r"];	

	for(i=0; i<[lines count]; i++)
	{		
		NSScanner *scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];		
		if( [scanner scanInt:&a1] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:&a2] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:&a3] &&
			[scanner scanCharactersFromSet:TMPlayerSep intoString:nil] &&
			[scanner scanInt:&l] &&
			[scanner scanCharactersFromSet:TMPlayerSep intoString:nil])
		{	
			if(subItem)
			{
				if(l==1)
				{
					[subItem setTimeHideText:(a1*3600*1000+a2*60*1000+a3*1000)-10];
				
					//Add only if the lines are not empty
					if([[subItem lines] count])
						[subtitleArray addObject:subItem];
					[subItem release];	
				}
			}
			
			if((l==1) || (subItem == NULL))
			{
				subItem = [SubtitleItem new];
				[subItem setTimeShowText:(a1*3600*1000+a2*60*1000+a3*1000)];
			}
			
			if(subItem)
			{	
				NSString *line = [[[lines objectAtIndex:i] substringFromIndex:[scanner scanLocation]]  stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]];
				if([line length])
					[subItem addLine:line];	
			}
		}	
		

	}
	//if last line add 5 seconds
	if(subItem)
	{
		[subItem setTimeHideText:(a1*3600*1000+a2*60*1000+(a3+5)*1000)];
		
		//Add only if the lines are not empty
		if([[subItem lines] count])
			[subtitleArray addObject:subItem];
		[subItem release];	
	}	
	
	return YES;
}

- (BOOL)removeAccents
{
	int i=0;	
	
	while(i<[subtitleArray count])
	{		
		[[subtitleArray objectAtIndex:i] removeAccents];
		i++;
	}
	return YES;
}

- (BOOL)removeStyleTags
{
	int i=0;	
	
	while(i<[subtitleArray count])
	{		
		[[subtitleArray objectAtIndex:i] removeStyleTags];
		i++;
	}
	return YES;
}

- (BOOL)deleteStringsBetween
{
	int i=0;	
	
	while(i<[subtitleArray count])
	{		
		[[subtitleArray objectAtIndex:i] deleteStringsBetween];
		i++;
	}
	return YES;
}

- (BOOL)addStringAtEnd:(NSString *)stringToAdd
{
	int i=0;	
	
	while(i<[subtitleArray count])
	{		
		[[subtitleArray objectAtIndex:i] addStringAtEnd:stringToAdd];
		i++;
	}
	return YES;
}

- (BOOL)wrapLines:(int)maxCharsPerLine withMaxLines:(int)maxLines
{
	int i=0;	
	
	while(i<[subtitleArray count])
	{	
		if((maxCharsPerLine>0) && (maxLines>0))
			if([[subtitleArray objectAtIndex:i] charsNo] > (maxCharsPerLine*maxLines))
				[self splitSubtitleItem:i atLine:maxLines];
		
		else if((maxCharsPerLine<0) && (maxLines>0))
			[self splitSubtitleItem:i atLine:maxLines];
		
		[[subtitleArray objectAtIndex:i] wrapLinesAtLength:maxCharsPerLine withMaxLines:maxLines];
		
		if(maxLines>0)
			[self splitSubtitleItem:i atLine:maxLines];
		
		i++;
	}
	return YES;
	
	
	
}

- (int)checkFormat:(NSString *)stringToCheck 
{	
    NSArray *lines = [stringToCheck componentsSeparatedByString:@"\n"];
	
	//if the lines count is 1 this file it's a classic mac text file, let's try again
	if([lines count] < 2)
		lines = [stringToCheck componentsSeparatedByString:@"\r"];
	
    NSCharacterSet *decimalSep = [NSCharacterSet characterSetWithCharactersInString:@"\\.,"];	
    NSCharacterSet *microDVDSep = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
    NSCharacterSet *TMPlayerSep = [NSCharacterSet characterSetWithCharactersInString:@":="];
	NSCharacterSet *MPL2Sep = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    int i;
	
	//Let's check the first lines...
    for(i=0; (i<100) && (i<[lines count]); i++)
    {
		//is SubRip format?
		NSLog([lines objectAtIndex:i]);
        NSScanner *scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];
		if( [scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@"-->" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			[scanner scanInt:nil])
		{	
			return 1;
		}
		//is SubViewer format?
		[scanner setScanLocation:0];
		if ([scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:decimalSep intoString:nil] &&
			[scanner scanInt:nil])
		{	
				return 2;
		}
		//is MicroDVD format?
		[scanner setScanLocation:0];
		if ([scanner scanCharactersFromSet:microDVDSep intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:microDVDSep intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:microDVDSep intoString:nil])
		{	
			return 3;
		}
		//is singleline TMPlayer?
        [scanner setScanLocation:0];
		if( [scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:TMPlayerSep intoString:nil])
		{
			return 4;
		}	
		//is multiline TMPlayer?
        [scanner setScanLocation:0];
		if( [scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@":" intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanString:@"," intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:TMPlayerSep intoString:nil])
		{
			return 5;
		}	
		//is MPL2
		[scanner setScanLocation:0];
		if ([scanner scanCharactersFromSet:MPL2Sep intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:MPL2Sep intoString:nil] &&
			[scanner scanInt:nil] &&
			[scanner scanCharactersFromSet:MPL2Sep intoString:nil])
		{	
			return 6;
		}	
	}
	return 0;
}

- (BOOL)splitSubtitleItem:(int)index atLine:(int)line
{
	int i;
	SubtitleItem *subItem = NULL;
	SubtitleItem *subItemSplit1 = NULL;
	SubtitleItem *subItemSplit2 = NULL;
	if(index >= [subtitleArray count])
		return NO;
	
	subItem = [subtitleArray objectAtIndex:index];
	
	if(line >= [[subItem lines] count])
		return NO;
	
	subItemSplit1 = [SubtitleItem new];
	subItemSplit2 = [SubtitleItem new];
	
	[subItemSplit1 setTimeShowText:[subItem timeShowText]];
	[subItemSplit1 setTimeHideText:[subItem timeShowText] + ((([subItem timeHideText] - [subItem timeShowText])/[[subItem lines] count])*line)-10];	
	
	for(i=0; i<line; i++)
		[subItemSplit1 addLine:[[subItem lines] objectAtIndex:i]];

	[subItemSplit2 setTimeShowText:[subItemSplit1 timeHideText] + 20];
	[subItemSplit2 setTimeHideText:[subItem timeHideText]];	
	
	for(i; i<[[subItem lines] count]; i++)
		[subItemSplit2 addLine:[[subItem lines] objectAtIndex:i]];
	
	
	[subtitleArray removeObjectAtIndex:index];
	[subtitleArray insertObject:subItemSplit2 atIndex:index];
	[subtitleArray insertObject:subItemSplit1 atIndex:index];
	[subItemSplit1 release];
	[subItemSplit2 release];
	
	return YES;
}


@end

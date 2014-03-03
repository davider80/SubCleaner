#import "AppController.h"
#import "DragFile.h"
#import "Subtitle.h"
#import "PreferenceController.h"
#import "DRFramerateProperty.h"


@implementation AppController

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:@"DRFirstStart"];
	[defaultValues setObject:@"1.0b3" forKey:@"DRLastVersionStart"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"DRWrapEnabled"];
	[defaultValues setObject:[NSNumber numberWithInt:50] forKey:@"DRLengthToWrap"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"DRLimitLinesEnabled"];
	[defaultValues setObject:[NSNumber numberWithInt:3] forKey:@"DRLinesToLimit"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"DRRemoveStyleTagsEnabled"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"DRDeleteStringsBetweenEnabled"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"DRAddACharacterAtTheEndEnabled"];
	[defaultValues setObject:[NSString stringWithString:@" "] forKey:@"DRCharacterToAdd"];
	[defaultValues setObject:[NSNumber numberWithFloat:25.0] forKey:@"DRSubtitleFramerate"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"DRMinimumSubDurationEnabled"];
	[defaultValues setObject:[NSNumber numberWithInt:100] forKey:@"DRMinimumSubDuration"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"DRRemoveAccentsEnabled"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	NSLog(@"registered defaults");
}

- (id)init
{
	[super init];
	subtitleData = [Subtitle new];
	growlController = [GrowlController new];
	[growlController registerToGrowl];
	framerateContent = [NSArray arrayWithObjects: 
		[[DRFramerateProperty alloc] initWithFPS:23.976 text:@"23.976 (FILM)"],
		[[DRFramerateProperty alloc] initWithFPS:24.0 text:@"24"],
		[[DRFramerateProperty alloc] initWithFPS:25.0 text:@"25 (PAL)"],
		[[DRFramerateProperty alloc] initWithFPS:29.97 text:@"29.97 (NTSC)"],
		[[DRFramerateProperty alloc] initWithFPS:30.0 text:@"30"],
		nil];	

	return self;
}

- (void)dealloc
{
	[subtitleData release];
	[growlController release];
	[preferenceController release];
	[super dealloc];
}


- (NSArray *)framerateContent
{
	return framerateContent;
}


- (void)application:(NSApplication *)sender openFiles:(NSArray *)files
{
	NSLog(@"Several files dragged");
	[self startSubtitlesProcessing:files];
}

- (IBAction)showPreferenceController:(id)sender
{
	if(!preferenceController) {
		preferenceController = [PreferenceController new];
	}
	
	[preferenceController showWindow:self];
}

- (IBAction)gotoHomePage:(id)sender
{
	NSURL *homePageUrl = [NSURL URLWithString:@"http://www.rivola.net/software/subcleaner/"];
	if([[NSWorkspace sharedWorkspace] openURL:homePageUrl])
		NSLog(@"Home page opened succesfully");
	else
		NSLog(@"Failed to open home page");
}


- (IBAction)gotoDonationPage:(id)sender
{
	//NSURL *homePageUrl = [NSURL URLWithString:@"https://www.paypal.com/xclick/business=davide@rivola.net&item_name=SubCleaner"];
	NSURL *homePageUrl = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=davide%40rivola%2enet&item_name=SubCleaner&no_shipping=1&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"];
	if([[NSWorkspace sharedWorkspace] openURL:homePageUrl])
		NSLog(@"Forums page opened succesfully");
	else
		NSLog(@"Failed to open forums page");
}




- (void)fileDragged:(DragFile *)sender
{
	[self startSubtitlesProcessing:[sender subtitlesFilenames]];
}


- (void)startSubtitlesProcessing:(NSArray *)subtitlesToProcess;
{
    NSLog(@"Button clicked in %@", [NSThread currentThread]);
	
    NSMutableDictionary *thingsIllNeed = [NSMutableDictionary dictionary];
    // Prep things we'll need in the other thread.
    // Any GUI components should be accessed this way.
 
    [thingsIllNeed setObject:dragFileView forKey:@"status"];	
    [thingsIllNeed setObject:subtitlesToProcess forKey:@"subtitles"];	
	[thingsIllNeed setObject:subtitleData forKey:@"subtitledata"];
	
    // Start work on new thread
    processSubtitlesThreadWorker = [[ThreadWorker workOn:self
											withSelector:@selector(processSubtitles:worker:)
											  withObject:thingsIllNeed
										  didEndSelector:@selector(processSubtitlesFinished:)] retain];
}	// end start:


-(id)processSubtitles:(id)userInfo worker:(ThreadWorker *)tw
{
	int					i;
    NSDictionary        *thingsIllNeedTW;
	DragFile			*dragFileViewTW;
	NSArray				*subtitlesToProcessTW;
	Subtitle			*subtitleDataTW;
    id                   returnVal;
	int					subsCorrectlyProcessed=0;
	int					subType;
	
	NSString *filename;
	
    // Get stuff I'll need to talk to on the other thread.
    thingsIllNeedTW		= (NSDictionary *)userInfo;
    dragFileViewTW		= (DragFile *)[thingsIllNeedTW objectForKey:@"status"];
    subtitlesToProcessTW	= (NSArray *)[thingsIllNeedTW objectForKey:@"subtitles"];
	subtitleDataTW		= (Subtitle *)[thingsIllNeedTW objectForKey:@"subtitledata"];
    returnVal			= nil;
	
    NSLog(@"processSubtitles task working in %@", [NSThread currentThread]);

	if([subtitlesToProcessTW count] < 2)
		[dragFileViewTW setState:0];
	else
		[dragFileViewTW setState:3];		
	
	for(i=0; i<[subtitlesToProcessTW count]; i++)
	{
	
		filename = [subtitlesToProcessTW objectAtIndex:i];
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:filename traverseLink:YES];
		
		if (fileAttributes != nil) 
		{	
			NSNumber *fileSize;
			if (fileSize = [fileAttributes objectForKey:NSFileSize]) 
			{
				//Let's verify that the file is less than 1MB
				if([fileSize unsignedLongLongValue] < 1048576)
				{
					NSLog(@"File size: %qi\n", [fileSize unsignedLongLongValue]);
					
					switch(subType = [subtitleDataTW loadFromFile:filename])
					{
						case 0:
							NSLog(@"Subtitle: is not a known subtitle format");
							break;
						case 1:
							NSLog(@"Subtitle: is a SubRip subtitle");
							[subtitleDataTW importSubRip];
							break;
						case 2:
							NSLog(@"Subtitle: is a SubViewer subtitle");
							[subtitleData importSubViewer];
							break;
						case 3:
							NSLog(@"Subtitle: is a MicroDVD subtitle");
							[microDVDSubName setAttributedStringValue:[filename lastPathComponent]];
							[self showFramerateSheet];
							NSLog(@"Framerate has been choosed");
							[subtitleDataTW importMicroDVD:[[NSUserDefaults standardUserDefaults] floatForKey:@"DRSubtitleFramerate"]];
							break;	
						case 4:
							NSLog(@"Subtitle: is a TMPlayer singleline subtitle");
							[subtitleData importSingleLineTMPlayer];
							break;
						case 5:
							NSLog(@"Subtitle: is a TMPlayer multiline subtitle");
							[subtitleData importMultiLineTMPlayer];
							break;
					}
					
					if(subType)
					{
						//Remove style tags
						
						
						if([[NSUserDefaults standardUserDefaults] boolForKey:@"DRRemoveAccentsEnabled"]) 
							[subtitleDataTW removeAccents];
						
						if([[NSUserDefaults standardUserDefaults] boolForKey:@"DRRemoveStyleTagsEnabled"]) 
							[subtitleDataTW removeStyleTags];
						
						//Delete strings between []
						if([[NSUserDefaults standardUserDefaults] boolForKey:@"DRDeleteStringsBetweenEnabled"]) 
							[subtitleDataTW deleteStringsBetween];
						
						if([[NSUserDefaults standardUserDefaults] boolForKey:@"DRAddACharacterAtTheEndEnabled"]) 
							[subtitleDataTW addStringAtEnd:[[NSUserDefaults standardUserDefaults] stringForKey:@"DRCharacterToAdd"]];
					
						//Wrap lines routines
						if(([[NSUserDefaults standardUserDefaults] boolForKey:@"DRWrapEnabled"]) && ([[NSUserDefaults standardUserDefaults] boolForKey:@"DRLimitLinesEnabled"]))
						{
							[subtitleDataTW wrapLines:[[NSUserDefaults standardUserDefaults] integerForKey:@"DRLengthToWrap"] withMaxLines:[[NSUserDefaults standardUserDefaults] integerForKey:@"DRLinesToLimit"]];
						}
						else if(([[NSUserDefaults standardUserDefaults] boolForKey:@"DRWrapEnabled"]) && (![[NSUserDefaults standardUserDefaults] boolForKey:@"DRLimitLinesEnabled"]))
						{
							[subtitleDataTW wrapLines:[[NSUserDefaults standardUserDefaults] integerForKey:@"DRLengthToWrap"] withMaxLines:-1];
						}
						else if((![[NSUserDefaults standardUserDefaults] boolForKey:@"DRWrapEnabled"]) && ([[NSUserDefaults standardUserDefaults] boolForKey:@"DRLimitLinesEnabled"]))
						{
							[subtitleDataTW wrapLines:-1 withMaxLines:[[NSUserDefaults standardUserDefaults] integerForKey:@"DRLinesToLimit"]];
						}	
								
						int j;
		
						NSString *fileName, *fileSuffix;
						
						fileName = [[filename lastPathComponent] stringByDeletingPathExtension];
						fileSuffix = [filename pathExtension];
			
						[[NSFileManager defaultManager] createDirectoryAtPath:[[filename stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Original Subtitles"] attributes:nil];	
						
						if(![fileSuffix isEqualToString:@"srt"])
						{
							[[NSFileManager defaultManager] movePath:[[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"] toPath:[[[[filename stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Original Subtitles"] stringByAppendingPathComponent:fileName]  stringByAppendingPathExtension:@"srt"]
														 handler:nil];
						}
						
						if(![[NSFileManager defaultManager] movePath:filename toPath:[[[[filename stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Original Subtitles"] stringByAppendingPathComponent:fileName]  stringByAppendingPathExtension:fileSuffix]
															 handler:nil])
						{
							j=1;		
							while(![[NSFileManager defaultManager]	movePath:filename toPath:[[[[filename stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Original Subtitles"] stringByAppendingPathComponent:[fileName stringByAppendingFormat:@"-%d",j]]  stringByAppendingPathExtension:fileSuffix]
																		handler:nil])
							{
								j++;
							}
						}
												
						NSLog([[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"]);
						[subtitleDataTW saveToFile:[[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"srt"]];
						subsCorrectlyProcessed++;

					}
					
				}
				else
				{
					NSLog(@"File to big! size: %qi\n", [fileSize unsignedLongLongValue]);
				}
			}
			else
				NSLog(@"Path (%@) is invalid.", filename);
		}
		
		//[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
		[dragFileViewTW setProgress:((float)(i+1)/(float)[subtitlesToProcessTW count])*100];	
	}
	
	if(subsCorrectlyProcessed)
	{
		if([subtitlesToProcessTW count]==1)
			[growlController displayCleanSuccessful:[subtitlesToProcessTW objectAtIndex:0]];
		else
			[growlController displayNumberMultiCleanSuccessful:subsCorrectlyProcessed ofTotal:[subtitlesToProcessTW count]];
		
		[dragFileViewTW setState:2];
	}
	else
		[dragFileViewTW setState:1];		
	
	
	
	
    return returnVal;
}	// end longTask:



-(void)processSubtitlesFinished:(id)userInfo
{	
	[processSubtitlesThreadWorker release];
    processSubtitlesThreadWorker = nil;
}	// end longTaskFinished




- (void) applicationDidFinishLaunching: (NSNotification *) aNotification 
{
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"DRFirstStart"])
	{
		[NSApp beginSheet:welcomeSheet modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
			  contextInfo:nil];
		NSLog(@"first start of the application");
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"DRFirstStart"];
		[[NSUserDefaults standardUserDefaults] setObject:@"1.0b5" forKey:@"DRLastVersionStart"];
	}
	/*else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"DRLastVersionStart"] compare:@"1.0b5" options:NSNumericSearch] == NSOrderedAscending) 
	{
		
		[NSApp beginSheet:welcomeBackSheet modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
			  contextInfo:nil];
		NSLog(@"show welcome back");	
		
		[[NSUserDefaults standardUserDefaults] setObject:@"1.0b5" forKey:@"DRLastVersionStart"];
	}*/
		
}

- (void)showFramerateSheet
{
	[NSApp beginSheet:framerateSheet modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil];	
	[NSApp runModalForWindow:framerateSheet];
}


- (IBAction)letsstartButtonClicked:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]] == YES)
    {
        [NSApp endSheet:[sender window] 
			 returnCode:NSRunStoppedResponse];
    }	
}

- (IBAction)letsstartWelcomeBackButtonClicked:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]] == YES)
    {
        [NSApp endSheet:[sender window] 
			 returnCode:NSRunStoppedResponse];
    }	
}

- (IBAction)framerateButtonClicked:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]] == YES)
    {
        [NSApp endSheet:[sender window] 
			 returnCode:NSRunStoppedResponse];
    }	
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if(sheet == welcomeSheet)
    {
		if (returnCode == NSRunStoppedResponse)
		{

		}
		[welcomeSheet close];
    }
    if(sheet == welcomeBackSheet)
    {
		if (returnCode == NSRunStoppedResponse)
		{
			
		}
		[welcomeBackSheet close];
    }
	if(sheet == framerateSheet)
    {
		if (returnCode == NSRunStoppedResponse)
		{
			
		}
		[NSApp stopModal];
		[framerateSheet close];
    }
}

-(void)awakeFromNib
{
	if (![mainWindow setFrameUsingName:@"Main Window"]) [mainWindow center];
}

@end

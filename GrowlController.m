//
//  GrowlController.m
//  SubCleaner
//
//  Created by Davide Rivola on 28.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "GrowlController.h"


@implementation GrowlController

- (void)registerToGrowl;
{
	[GrowlApplicationBridge setGrowlDelegate:self];
}

- (void)displayCleanSuccessful:(NSString *)fileName
{
	[GrowlApplicationBridge notifyWithTitle:@"Succesful Clean"
								description:[NSString stringWithFormat:@"%@", [fileName lastPathComponent]]
						   notificationName:@"Succesful Clean"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

- (void)displayNumberMultiCleanSuccessful:(int)subsCorrectlyProcessed ofTotal:(int)totalSubtitles
{
	NSString *desc;
	
	if(subsCorrectlyProcessed == totalSubtitles)
		desc = @"All the subtitles have been cleaned";
	else {
		desc = [NSString stringWithFormat:@"%d of %d subtitles have been cleaned", subsCorrectlyProcessed, totalSubtitles];
	}

	
	[GrowlApplicationBridge notifyWithTitle:@"Succesful Clean"
								description:desc
						   notificationName:@"Succesful Clean"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

- (NSDictionary *) registrationDictionaryForGrowl;						
{
	NSArray* notifications = [NSArray arrayWithObjects:@"Succesful Clean", nil];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		notifications, GROWL_NOTIFICATIONS_ALL, 
		notifications, GROWL_NOTIFICATIONS_DEFAULT, 
		nil];
	
	return dict;
}

@end

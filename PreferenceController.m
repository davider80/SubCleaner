//
//  PreferenceController.m
//  SubCleaner
//
//  Created by Davide Rivola on 28.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"


@implementation PreferenceController

- (id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)windowDidLoad
{

}

- (void)awakeFromNib
{
	if (![[super window] setFrameUsingName:@"Prefs Window"]) [[super window] center];
}

@end

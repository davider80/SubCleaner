//
//  DRFramerateProperty.m
//  SubCleaner
//
//  Created by Davide Rivola on 12.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DRFramerateProperty.h"

@implementation DRFramerateProperty

- (id)init
{
	[super init];
	fps = 0;
	name = @"";
	return self;
}

- (id)initWithFPS:(float)framerate text:(NSString *)text
{
	[super init];
	fps = framerate;
	name = text;
	return self;
}

- (float)fps
{
	return fps;
}

- (NSString *)name
{
	return name;
}

- (void)dealloc
{
	[super dealloc];
}



@end

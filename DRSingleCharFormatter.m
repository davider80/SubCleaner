//
//  DRSingleCharFormatter.m
//  SubCleaner
//
//  Created by Davide Rivola on 05.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DRSingleCharFormatter.h"


@implementation DRSingleCharFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **) newString errorDescription:(NSString **)error
	/* this validates the field's value as each key is entered into textfield */
{
	/* validate the partial string */
	
	if([partialString length] > 1)
	{
		NSBeep();
		return FALSE;			
	}
	else
	{
		return TRUE;
	}
}

-(NSString *)stringForObjectValue:(id)obj
{
	return obj;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string 
	  errorDescription:(NSString **)error
{
    return YES;
}

@end

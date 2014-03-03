//
//  DRNumberFormatter.m
//  SubCleaner
//
//  Created by Davide Rivola on 05.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DRNumberFormatter.h"

@implementation DRNumberFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString 
			newEditingString:(NSString **)newString errorDescription:(NSString 
																	  **)error
	/* this validates the field's value as each key is entered into textfield */
{
	/* validate the partial string */
	NSDecimalNumber *check; /* used to hold temp value */ 
	if ([self getObjectValue:&check forString:partialString 
			errorDescription:error]) {return TRUE;}
	else
	{
		NSBeep();
		return FALSE;
	}
}



@end

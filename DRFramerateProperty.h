//
//  DRFramerateProperty.h
//  SubCleaner
//
//  Created by Davide Rivola on 12.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DRFramerateProperty : NSObject {
	float fps;
	NSString* name;
}

- (id)initWithFPS:(float)framerate text:(NSString *)text;
- (float)fps;
- (NSString *)name;

@end

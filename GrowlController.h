//
//  GrowlController.h
//  SubCleaner
//
//  Created by Davide Rivola on 28.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Growl.h"
@protocol GrowlApplicationBridgeDelegate;

@interface GrowlController : NSObject<GrowlApplicationBridgeDelegate> {
}

- (void)registerToGrowl;
- (void)displayCleanSuccessful:(NSString *)fileName;
- (void)displayNumberMultiCleanSuccessful:(int)subsCorrectlyProcessed ofTotal:(int)totalSubtitles;

@end

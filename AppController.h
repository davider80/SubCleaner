/* AppController */

#import <Cocoa/Cocoa.h>
#import "GrowlController.h"
#import "ThreadWorker.h"

@class PreferenceController;
@class Subtitle;
@class DragFile;

@interface AppController : NSObject
{
	Subtitle *subtitleData;
	IBOutlet DragFile *dragFileView;
	GrowlController *growlController;
	PreferenceController *preferenceController;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *welcomeSheet;
	IBOutlet NSWindow *welcomeBackSheet;
	IBOutlet NSWindow *framerateSheet;
	IBOutlet NSTextField *microDVDSubName;
	NSArray *framerateContent;
	ThreadWorker *processSubtitlesThreadWorker;

}

- (void)startSubtitlesProcessing:(NSArray *)subtitlesToProcess;
- (id)processSubtitles:(id)userInfo worker:(ThreadWorker *)tw;
- (void)processSubtitlesFinished:(id)userInfo;

- (NSArray *)framerateContent;	
- (IBAction)showPreferenceController:(id)sender;
- (IBAction)letsstartButtonClicked:(id)sender;
- (IBAction)letsstartWelcomeBackButtonClicked:(id)sender;
- (IBAction)framerateButtonClicked:(id)sender;
- (IBAction)gotoHomePage:(id)sender;
- (IBAction)gotoDonationPage:(id)sender;
- (void)fileDragged:(DragFile *)sender;
- (void)showFramerateSheet;

@end

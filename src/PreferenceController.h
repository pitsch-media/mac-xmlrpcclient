//
//  PreferenceController.h
//  XML Nanny
//
//  Created by Todd Ditchendorf on 8/27/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *PlaySoundKey;
extern NSString *SuccessSoundNameKey;
extern NSString *FailureSoundNameKey;

extern BOOL PlaySoundValue;
extern NSString *SuccessSoundNameValue;
extern NSString *FailureSoundNameValue;

@interface PreferenceController : NSWindowController {
	IBOutlet NSButton *playSoundCheckbox;
	IBOutlet NSPopUpButton *successSoundNamePopUp;
	IBOutlet NSPopUpButton *failureSoundNamePopUp;
	IBOutlet NSTextField *successSoundNameTextField;
	IBOutlet NSTextField *failureSoundNameTextField;
}

- (IBAction)changePlaySound:(id)sender;
- (IBAction)changeSuccessSoundName:(id)sender;
- (IBAction)changeFailureSoundName:(id)sender;
- (void)initPopUpItemsForPopUp:(NSPopUpButton *)popUp withSelectedTitle:(NSString *)selectedTitle;
- (BOOL)playSound;
- (NSString *)successSoundName;
- (NSString *)failureSoundName;
@end

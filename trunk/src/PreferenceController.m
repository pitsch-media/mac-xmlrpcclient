//
//  PreferenceController.m
//  XML Nanny
//
//  Created by Todd Ditchendorf on 8/27/05.
//  Copyright 2005 Todd Ditchendorf. All rights reserved.
//

#import "PreferenceController.h"

NSString *PlaySoundKey = @"PlaySound";
NSString *SuccessSoundNameKey = @"SuccessSoundName";
NSString *FailureSoundNameKey = @"FailureSoundName";

BOOL PlaySoundValue = YES;
NSString *SuccessSoundNameValue = @"Hero";
NSString *FailureSoundNameValue = @"Basso";

@implementation PreferenceController

- (id)init {
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void)windowDidLoad {
	BOOL soundEnabled = [self playSound];
	[playSoundCheckbox setState:soundEnabled];
	
	[self initPopUpItemsForPopUp:successSoundNamePopUp 
			   withSelectedTitle:[self successSoundName]];
	[self initPopUpItemsForPopUp:failureSoundNamePopUp 
			   withSelectedTitle:[self failureSoundName]];

	[successSoundNamePopUp	   setEnabled:soundEnabled];
	[failureSoundNamePopUp     setEnabled:soundEnabled];
	[successSoundNameTextField setEnabled:soundEnabled];
	[failureSoundNameTextField setEnabled:soundEnabled];
}

- (void) initPopUpItemsForPopUp:(NSPopUpButton *)popUp withSelectedTitle:(NSString *)selectedTitle {
	[popUp removeAllItems];
	[popUp addItemWithTitle:@"Hero"];
	[popUp addItemWithTitle:@"Basso"];
	[popUp addItemWithTitle:@"Blow"];
	[popUp addItemWithTitle:@"Bottle"];
	[popUp addItemWithTitle:@"Frog"];
	[popUp addItemWithTitle:@"Funk"];
	[popUp addItemWithTitle:@"Glass"];
	[popUp addItemWithTitle:@"Hero"];
	[popUp addItemWithTitle:@"Morse"];
	[popUp addItemWithTitle:@"Ping"];
	[popUp addItemWithTitle:@"Pop"];
	[popUp addItemWithTitle:@"Purr"];
	[popUp addItemWithTitle:@"Sosumi"];
	[popUp addItemWithTitle:@"Submarine"];
	[popUp addItemWithTitle:@"Tink"];
	[popUp selectItemWithTitle:selectedTitle];
}


#pragma mark -
#pragma mark Actions

- (IBAction)changePlaySound:(id)sender {
	BOOL soundEnabled = [sender state];
	[successSoundNamePopUp	   setEnabled:soundEnabled];
	[failureSoundNamePopUp     setEnabled:soundEnabled];
	[successSoundNameTextField setEnabled:soundEnabled];
	[failureSoundNameTextField setEnabled:soundEnabled];
	[[NSUserDefaults standardUserDefaults] setBool:soundEnabled forKey:PlaySoundKey];
}

- (IBAction)changeSuccessSoundName:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[sender titleOfSelectedItem] forKey:SuccessSoundNameKey];
}

- (IBAction)changeFailureSoundName:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[sender titleOfSelectedItem] forKey:FailureSoundNameKey];
}


#pragma mark -
#pragma mark Other

- (BOOL)playSound {
	return [[NSUserDefaults standardUserDefaults] boolForKey:PlaySoundKey];
}

- (NSString *)successSoundName {
	return [[NSUserDefaults standardUserDefaults] stringForKey:SuccessSoundNameKey];
}

- (NSString *)failureSoundName {
	return [[NSUserDefaults standardUserDefaults] stringForKey:FailureSoundNameKey];
}

@end
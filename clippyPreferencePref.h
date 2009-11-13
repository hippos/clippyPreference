//
//  clippyPreferencePref.h
//  clippyPreference
//
//  Created by hippos on 09/11/12.
//  Copyright (c) 2009 hippos-lab.com. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>


@interface clippyPreferencePref : NSPreferencePane 
{
  unsigned int          hisval_;
  IBOutlet NSTextField *clippyTextPath;
  IBOutlet NSTextField *clippyMaxHistory;
  IBOutlet NSTextField *clippyHotKey;
  IBOutlet NSStepper   *stepper;
  CFStringRef           appID;
}

- (void)     mainViewDidLoad;
- (IBAction) clippyTextPathClicked:(id)sender;
- (IBAction) clippyHotKeyClicked:(id)sender;
- (IBAction) clippyStepperClicked:(id)sender;

@property (nonatomic, readwrite) unsigned int history_value;


@end

//
//  clippyPreferencePref.m
//  clippyPreference
//
//  Created by hippos on 09/11/12.
//  Copyright (c) 2009 hippos-lab.com. All rights reserved.
//

#import "clippyPreferencePref.h"
#import "PTHotKey/PTHotKey.h"
#import "PTHotKey/PTHotKeyCenter.h"
#import "PTHotKey/PTKeyComboPanel.h"

@implementation clippyPreferencePref

@synthesize history_value = hisval_;

- (id)initWithBundle:(NSBundle *)bundle
{
  if ((self = [super initWithBundle:bundle]))
  {
    appID = CFSTR("com.hippos-lab.clippyPreference");
  }
  return self;
}

- (void) mainViewDidLoad
{

  CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR("clippytext"), appID);
  if ((value && CFGetTypeID(value)) == CFBooleanGetTypeID())
  {
    [useClippyText setState:CFBooleanGetValue(value)];
    CFRelease(value);
  }
  else 
  {
    [useClippyText setState:YES];
  }
  
  value = CFPreferencesCopyAppValue(CFSTR("history"), appID);
  if ((value && CFGetTypeID(value)) == CFNumberGetTypeID())
  {
    CFNumberGetValue(value,kCFNumberSInt64Type,&hisval_);
    CFRelease(value);
  }
  else 
  {
    hisval_ = 10;
  }

  [clippyMaxHistory setIntegerValue:hisval_];

  CFPropertyListRef clippytext = CFPreferencesCopyAppValue(CFSTR("text"), appID);  
  if ((clippytext && CFGetTypeID(clippytext)) == CFStringGetTypeID())
  {
    [clippyTextPath setStringValue:(NSString*)clippytext];
  }
  else 
  {
    [clippyTextPath setStringValue:@""];
  }
  if ([useClippyText state] == YES)
  {
    [[clippyTextPath cell] setState:NO];
  }
  if (clippytext) CFRelease(clippytext);

  [selecPathButton setEnabled:![useClippyText state]];
  
  // default key-combo cmd + opt + c
  int               k     = 8;
  unsigned int      m     = cmdKey + optionKey;
  
  CFPropertyListRef keyCombo = CFPreferencesCopyAppValue(CFSTR("keyCode"), appID);
  if ((keyCombo && CFGetTypeID(keyCombo)) == CFNumberGetTypeID())
  {
    CFNumberGetValue(keyCombo, kCFNumberNSIntegerType, &k);
  }
  keyCombo = CFPreferencesCopyAppValue(CFSTR("modifiers"), appID);
  if ((keyCombo && CFGetTypeID(keyCombo)) == CFNumberGetTypeID())
  {
    CFNumberGetValue(keyCombo, kCFNumberNSIntegerType, &m);
  }
  PTKeyCombo *kc = [[PTKeyCombo alloc] initWithKeyCode:k modifiers:m];
  if (clippyHotKey)
  {
    [clippyHotKey setStringValue: [kc description]];
  }
  if (keyCombo) CFRelease(keyCombo);
  [kc release];
}

- (IBAction) useClippyTextClicked:(id)sender
{
  [selecPathButton setEnabled:![useClippyText state]];
}

- (IBAction) clippyTextPathClicked:(id)sender
{
	NSOpenPanel* op = [NSOpenPanel openPanel];
	NSArray* ext = [NSArray arrayWithObjects:@"txt",@"text",nil];
	if ([op runModalForDirectory:NSHomeDirectory() file:nil types:ext] != NSFileHandlingPanelOKButton)
  {
    return;
  }

//  CFPreferencesSetAppValue(CFSTR("clippytext"),[op filename],appID);
  [clippyTextPath setStringValue:[[op filename] lastPathComponent]];
}

- (IBAction) clippyHotKeyClicked:(id)sender
{
}

- (IBAction) clippyStepperClicked:(id)sender
{
  [clippyMaxHistory setIntegerValue:hisval_];
}

@end
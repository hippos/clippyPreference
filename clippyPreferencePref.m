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
    appID = CFSTR("com.hippos-lab.clippy");
  }
  return self;
}

- (void) mainViewDidLoad
{

  CFPropertyListRef clippytext = CFPreferencesCopyAppValue(CFSTR("text"), appID);  
  if (clippyTextPath)
  {
    if ((clippytext && CFGetTypeID(clippytext)) == CFStringGetTypeID())
    {
      [clippyTextPath setStringValue:(NSString*)clippytext];
    }
    else 
    {
      [clippyTextPath setStringValue:@"clippy internal"];
    }
  }
  if (clippytext) CFRelease(clippytext);
  
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

- (IBAction) clippyTextPathClicked:(id)sender
{

}

- (IBAction) clippyHotKeyClicked:(id)sender
{
}

- (IBAction) clippyStepperClicked:(id)sender
{
  [clippyMaxHistory setIntegerValue:hisval_];
}

@end
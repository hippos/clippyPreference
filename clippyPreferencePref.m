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
  if ((self = [super initWithBundle:bundle]) != nil)
  {
    appID = CFSTR("com.hippos-lab.clippy");
  }
  return self;
}

- (void) mainViewDidLoad
{

  hisval_ = 10;
  [useClippyText setState:YES];
  [clippyMaxHistory setIntegerValue:hisval_];
  [stepper setIntegerValue:hisval_];
  [selecPathButton setEnabled:![useClippyText state]];
  [clippyTextPath setStringValue:@""];

  CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR("useClippyText"), appID);
  if (value && (CFGetTypeID(value) == CFBooleanGetTypeID()))
  {
    [useClippyText setState:CFBooleanGetValue(value)];
  }
  if (value)
  {
    CFRelease(value);
  }

  value = CFPreferencesCopyAppValue(CFSTR("history"), appID);
  if (value && (CFGetTypeID(value) == CFNumberGetTypeID()))
  {
    CFNumberGetValue(value, kCFNumberSInt32Type, &hisval_);
    [clippyMaxHistory setIntegerValue:hisval_];
    [stepper setIntegerValue:hisval_];
  }
  if (value)
  {
    CFRelease(value);
  }

  if ([useClippyText state] == NO)
  {
    value = CFPreferencesCopyAppValue(CFSTR("textPath"), appID);
    if (value && (CFGetTypeID(value) == CFStringGetTypeID()))
    {
      [clippyTextPath setStringValue:(NSString *)value];
    }
    if (value)
    {
      CFRelease(value);
    }
  }

  PTKeyCombo *keyCombo = [self keyComboFromPref];
  [self regHotKey:keyCombo];
  [keyCombo release];
}

- (IBAction) useClippyTextClicked:(id)sender
{
  [selecPathButton setEnabled:![useClippyText state]];
  if ([useClippyText state])
  {
    CFPreferencesSetAppValue(CFSTR("useClippyText"), kCFBooleanTrue, appID);
    [clippyTextPath setStringValue:@""];
  }
  else
  {
    CFPreferencesSetAppValue(CFSTR("useClippyText"), kCFBooleanFalse, appID);
  }
}

- (IBAction) clippyTextPathClicked:(id)sender
{
	NSOpenPanel* op = [NSOpenPanel openPanel];
	NSArray* ext = [NSArray arrayWithObjects:@"txt",@"text",nil];
	if ([op runModalForDirectory:NSHomeDirectory() file:nil types:ext] != NSFileHandlingPanelOKButton)
  {
    return;
  }
  [clippyTextPath setStringValue:[[op filename] lastPathComponent]];
  CFPreferencesSetAppValue(CFSTR("textPath"),[op filename],appID);
}

- (IBAction) clippyHotKeyClicked:(id)sender
{
  PTKeyCombo *keyCombo     = [self keyComboFromPref];
  PTHotKey   *hotKey       = [[PTHotKey alloc] initWithIdentifier: @"clippyHotKey" keyCombo:keyCombo];
  [hotKey setName: @"clippy HotKey"];
  PTKeyComboPanel *panel = [PTKeyComboPanel sharedPanel];
  [panel setKeyCombo: [hotKey keyCombo]];
  [panel setKeyBindingName: [hotKey name]];
  if ([panel runModal] == NSOKButton)
  {
    [self regHotKey:[panel keyCombo]];
  }
  [keyCombo release];
}

- (IBAction) clippyStepperClicked:(id)sender
{
  [clippyMaxHistory setIntegerValue:hisval_];
  CFNumberRef h = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&hisval_);
  CFPreferencesSetAppValue(CFSTR("history"),h,appID);
  CFRelease(h);
}

- (PTKeyCombo*)keyComboFromPref
{
  NSInteger         k     = 8;
  NSUInteger        m     = cmdKey + optionKey;

  CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR("clippyKeyCombo"), appID);
  if (value && (CFGetTypeID(value) == CFDictionaryGetTypeID()))
  {
    CFNumberRef numref = CFDictionaryGetValue(value, CFSTR("keyCode"));
    if (numref)
    {
      CFNumberGetValue(numref, kCFNumberNSIntegerType, &k);
    }
    numref = CFDictionaryGetValue(value, CFSTR("modifiers"));
    if (numref)
    {
      CFNumberGetValue(numref, kCFNumberNSIntegerType, &m);
    }
  }
  if (value)
  {
    CFRelease(value);
  }
  PTKeyCombo *keyCombo = [[PTKeyCombo alloc] initWithKeyCode:k modifiers:m];
  return keyCombo;
}

- (void)regHotKey:(PTKeyCombo *)keyCombo
{
  [clippyHotKey setStringValue: [keyCombo description]];

  NSInteger   k  = [keyCombo keyCode];
  NSUInteger  m  = [keyCombo modifiers];
  CFNumberRef kk = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &k);
  CFNumberRef mm = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &m);

  CFStringRef keys[2];
  CFNumberRef values[2];

  keys[0]   = CFSTR("keyCode");
  values[0] = kk;
  keys[1]   = CFSTR("modifiers");
  values[1] = mm;

  const CFDictionaryKeyCallBacks   keyCB = kCFCopyStringDictionaryKeyCallBacks;
  const CFDictionaryValueCallBacks valCB = kCFTypeDictionaryValueCallBacks;
  CFDictionaryRef                  dic   =
    CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 2, &keyCB, &valCB);
  CFPreferencesSetAppValue(CFSTR("clippyKeyCombo"),dic,appID);

  CFRelease(kk);
  CFRelease(mm);
  CFRelease(dic);
}

- (void)didSelect
{
  /* nothing todo(now) */
}

- (void)didUnselect
{
  if ([useClippyText state] == YES)
  {
    CFPreferencesSetAppValue(CFSTR("textPath"),NULL,appID);
  }
  CFPreferencesAppSynchronize(appID);
}

@end
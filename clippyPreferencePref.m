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

EventHotKeyRef hot_key_ref;

@implementation clippyPreferencePref

@synthesize history_value = hisval_;

- (id)initWithBundle:(NSBundle *)bundle
{
  if ((self = [super initWithBundle:bundle]) != nil)
  {
    appID = CFSTR("com.hippos-lab.clippyPreference");
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
  [clippyHotKey setStringValue: [keyCombo description]];
  [self regHotKey:keyCombo update:NO];
  NSInteger   k  = [keyCombo keyCode];
  NSUInteger  m  = [keyCombo modifiers];
  CFNumberRef kk = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &k);
  CFNumberRef mm = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &m);

  CFPreferencesSetAppValue(CFSTR("keyCode"), kk, appID);
  CFPreferencesSetAppValue(CFSTR("modifiers"), mm, appID);
  [keyCombo release];
  CFRelease(kk);
  CFRelease(mm);
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
    [self regHotKey:[panel keyCombo] update:YES];
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
  NSInteger         k = 8;
  NSUInteger        m = cmdKey + optionKey;

  CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR("keyCode"), appID);
  if (value && (CFGetTypeID(value) == CFNumberGetTypeID()))
  {
    CFNumberGetValue(value, kCFNumberNSIntegerType, &k);
  }
  value = CFPreferencesCopyAppValue(CFSTR("modifiers"), appID);
  if (value && (CFGetTypeID(value) == CFNumberGetTypeID()))
  {
    CFNumberGetValue(value, kCFNumberNSIntegerType, &m);
  }
  PTKeyCombo* kc = [[PTKeyCombo alloc] initWithKeyCode:k modifiers:m];
  return kc;
}

- (void)regHotKey:(PTKeyCombo *)keyCombo update:(BOOL)update
{
  if (update)
  {
    UnregisterEventHotKey(hot_key_ref);
  }
  /* install hot key */
  EventHotKeyID hot_key_id;
  hot_key_id.signature = 'clp1';
  hot_key_id.id        = 1;
  RegisterEventHotKey([keyCombo keyCode], [keyCombo modifiers], hot_key_id, GetApplicationEventTarget(), 0, &hot_key_ref);
  [clippyHotKey setStringValue: [keyCombo description]];

  NSInteger   k  = [keyCombo keyCode];
  NSUInteger  m  = [keyCombo modifiers];
  CFNumberRef kk = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &k);
  CFNumberRef mm = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &m);

  CFPreferencesSetAppValue(CFSTR("keyCode"), kk, appID);
  CFPreferencesSetAppValue(CFSTR("modifiers"), mm, appID);

  CFRelease(kk);
  CFRelease(mm);
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
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

static CFStringRef appID              = CFSTR("com.hippos-lab.clippy");
/* clippy preference keys */
static CFStringRef cfUseClippyText    = CFSTR("useClippyText");
static CFStringRef cfClippyMaxHistory = CFSTR("clippyMaxHistory");
static CFStringRef cfClippyTextPath   = CFSTR("clippyTextPath");
static CFStringRef cfClippyKeyCombo   = CFSTR("clippyKeyCombo");
static CFStringRef cfKeyCode          = CFSTR("keyCode");
static CFStringRef cfModifiers        = CFSTR("modifiers");
static NSString   *nsUseClippyText    = @"useClippyText";
static NSString   *nsClippyMaxHistory = @"clippyMaxHistory";
static NSString   *nsClippyTextPath   = @"clippyTextPath";
static NSString   *nsClippyKeyCombo   = @"clippyKeyCombo";
static NSString   *nsKeyCode          = @"keyCode";
static NSString   *nsModifiers        = @"modifiers";

@implementation clippyPreferencePref

@synthesize history_value = hisval_;

- (id)initWithBundle:(NSBundle *)bundle
{
  self = [super initWithBundle:bundle];
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

  CFPropertyListRef value = CFPreferencesCopyAppValue(cfUseClippyText, appID);
  if (value && (CFGetTypeID(value) == CFBooleanGetTypeID()))
  {
    [useClippyText setState:CFBooleanGetValue(value)];
  }
  if (value)
  {
    CFRelease(value);
  }

  value = CFPreferencesCopyAppValue(cfClippyMaxHistory, appID);
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
    value = CFPreferencesCopyAppValue(cfClippyTextPath, appID);
    if (value && (CFGetTypeID(value) == CFStringGetTypeID()))
    {
      NSString  *temp = [NSString stringWithString:(NSString*)value];
      [clippyTextPath setStringValue:[temp lastPathComponent]];
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
    CFPreferencesSetAppValue(cfUseClippyText, kCFBooleanTrue, appID);
    CFPreferencesSetAppValue(cfClippyTextPath, NULL, appID);
    [clippyTextPath setStringValue:@""];
    [changeDict removeObjectForKey:nsClippyTextPath];
    [changeDict setValue:[NSNumber numberWithInteger:YES] forKey:nsUseClippyText];
  }
  else
  {
    CFPreferencesSetAppValue(cfUseClippyText, kCFBooleanFalse, appID);
    [changeDict setValue:[NSNumber numberWithInteger:NO] forKey:nsUseClippyText];
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
  [changeDict setValue:[op filename] forKey:nsClippyTextPath];
  [changeDict setValue:[NSNumber numberWithInteger:NO] forKey:nsUseClippyText];
  CFPreferencesSetAppValue(cfClippyTextPath,[op filename],appID);
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
    NSArray *keys = [NSArray arrayWithObjects:nsKeyCode,nsModifiers,nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[keyCombo keyCode]],[NSNumber numberWithInteger:[keyCombo modifiers]],nil];
    [changeDict setObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] forKey:nsClippyKeyCombo];
  }
  [keyCombo release];
}

- (IBAction) clippyStepperClicked:(id)sender
{
  [clippyMaxHistory setIntegerValue:hisval_];
  [changeDict setValue:[NSNumber numberWithInteger:hisval_] forKey:nsClippyMaxHistory];
  CFNumberRef h = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&hisval_);
  CFPreferencesSetAppValue(cfClippyMaxHistory,h,appID);
  CFRelease(h);
}

- (PTKeyCombo*)keyComboFromPref
{
  NSInteger         k     = 8;
  NSUInteger        m     = cmdKey + optionKey;

  CFPropertyListRef value = CFPreferencesCopyAppValue(cfClippyKeyCombo, appID);
  if (value && (CFGetTypeID(value) == CFDictionaryGetTypeID()))
  {
    CFNumberRef numref = CFDictionaryGetValue(value, cfKeyCode);
    if (numref)
    {
      CFNumberGetValue(numref, kCFNumberNSIntegerType, &k);
    }
    numref = CFDictionaryGetValue(value, cfModifiers);
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

  keys[0]   = cfKeyCode;
  values[0] = kk;
  keys[1]   = cfModifiers;
  values[1] = mm;

  const CFDictionaryKeyCallBacks   keyCB = kCFCopyStringDictionaryKeyCallBacks;
  const CFDictionaryValueCallBacks valCB = kCFTypeDictionaryValueCallBacks;
  CFDictionaryRef                  dic   =
    CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 2, &keyCB, &valCB);
  CFPreferencesSetAppValue(cfClippyKeyCombo,dic,appID);

  CFRelease(kk);
  CFRelease(mm);
  CFRelease(dic);
}

- (void)didSelect
{
  changeDict = [[NSMutableDictionary alloc] init];
}

- (void)didUnselect
{
  if (([useClippyText state] == NO) && ([[clippyTextPath stringValue] length] == 0))
  {
    [useClippyText setState:YES];
    [self useClippyTextClicked:self];
  }

  CFPreferencesAppSynchronize(appID);

  if ([changeDict count] > 0)
  {
    NSString                        *observedObject =
      [NSString stringWithFormat:@"%s", CFStringGetCStringPtr(appID, kCFStringEncodingASCII)];
    NSDistributedNotificationCenter *center         = [NSDistributedNotificationCenter defaultCenter];
    [center postNotificationName: @"clippyPref Notification" object: observedObject userInfo: changeDict
     deliverImmediately: YES]
    ;
  }
  [changeDict release];
}

@end
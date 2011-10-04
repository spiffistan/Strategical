//
//  StrategicalAppDelegate.m
//  Strategical
//
//  Created by Anders Aarsæther on 9/19/11.
//  Copyright 2011 Capasit. All rights reserved.
//

#import "StrategicalAppDelegate.h"


#include "CGSPrivate.h"

@implementation StrategicalAppDelegate

@synthesize window, calendarView, mainView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

    // [self enableBlurForWindow:window];
}

extern OSStatus CGSNewConnection(const void **attr, CGSConnectionID *id);

- (void)enableBlurForWindow:(NSWindow *)theWindow
{
    CGSConnectionID cid;
    CGSWindowFilterRef __compositingFilter;
    CGSWindow wn = (int) [theWindow windowNumber];
    
    int __compositingType = 1; 
        
    CGSNewConnection(NULL , &cid);
        
    CGSNewCIFilterByName(cid, (CFStringRef)@"CIGaussianBlur", &__compositingFilter);
    NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
    CGSSetCIFilterValuesFromDictionary(cid, __compositingFilter, (CFDictionaryRef)optionsDict);
    
    CGSAddWindowFilter(cid, wn, __compositingFilter, __compositingType );
}

- (void) connectToGoogleCalendar
{ 
}

@end

//
//  StrategicalAppDelegate.h
//  Strategical
//
//  Created by Anders on 9/19/11.
//  Copyright 2011 Capasit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CalendarView.h"

@interface StrategicalAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet CalendarView *calendarView;
    NSView *mainView;
//    GDataServiceGoogleCalendar *service;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CalendarView *calendarView;
@property (assign) IBOutlet NSView *mainView;

@end

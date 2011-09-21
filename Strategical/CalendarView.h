//
//  CalendarView.h
//  Strategical
//
//  Created by Anders on 9/19/11.
//  Copyright 2011 Capasit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CalendarView : NSView
{
    NSCalendar *gregorian;
    NSDate *today;
    NSDateComponents *todayComponents;
    
    NSMutableArray *dayPaths;
    
    NSUInteger daysInYear, monthsInYear;
    NSUInteger dayOfYear, monthOfYear, theYear;
        
    BOOL mouseClicked, mouseHovering;
    
    NSPoint clickLocation, hoverLocation;
    
    NSTrackingArea* trackingArea;

    enum month {
        JANUARY = 1,
        FEBRUARY,
        MARCH,
        APRIL,
        MAY,
        JUNE,
        JULY,
        AUGUST,
        SEPTEMBER,
        OCTOBER,
        NOVEMBER,
        DECEMBER
    };
    
}

- (NSBezierPath *) makeMonthPathFrom:(NSUInteger)fromDay to:(NSUInteger)toDay;

@end

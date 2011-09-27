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
    // Calendar objects
    NSCalendar *calendar;
    NSDate *today;
    NSDateComponents *todayComponents;
    NSUInteger components;
    
    NSUInteger daysInYear, weeksInYear, monthsInYear;
    NSUInteger dayOfYear, weekOfYear, monthOfYear, theYear;
    
    NSBezierPath *outerMaskPath, *innerMaskPath, *centerPath;
    
    // Path data structures
    NSMutableArray *dayPaths, *weekPaths, *monthPaths;
    NSMutableArray *days;

    BOOL mouseClicked, mouseHovering;
    
    NSPoint center;
    NSUInteger radiusDayStart, radiusDayEnd;
    NSUInteger radiusDayStartToday;
    NSPoint clickLocation, hoverLocation;
    
    IBOutlet NSTextField *dateLabel;
    
    NSTrackingArea* trackingArea;

    NSColor *colorToday;
    NSColor *colorWeekend;
    NSColor *colorEvent;
    NSColor *colorHover;
    
    NSColor *fill, *stroke; 
    CGFloat alpha;
    NSUInteger lastWeek;
    
    NSRect frame;
    NSUInteger radius;

}

@property (readwrite, assign) IBOutlet NSTextField *dateLabel;

- (NSArray *)createDayPathsAndDates;
- (NSMutableArray *)createMonthPaths;
- (NSMutableArray *)createWeekPaths;

- (void) drawDays:(NSRect)dirtyRect;
- (void) drawMonths:(NSRect)dirtyRect;
- (NSBezierPath *) makeDayPath:(NSUInteger)i;
- (NSBezierPath *) makePathFrom:(NSUInteger)fromDay to:(NSUInteger)toDay;

@end

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
    
    NSTextField *dateLabel;
    
    NSTrackingArea* trackingArea;
    NSUInteger dayHovering;

    NSColor *colorToday;
    NSColor *colorWeekend;
    NSColor *colorEvent;
    NSColor *colorHover;
    NSColor *colorDayPrimary, *colorDaySecondary;
    
    NSColor *fill, *stroke; 
    CGFloat alpha;
    NSUInteger lastWeek;
    
    NSRect frame;
    NSUInteger radius;
    
    NSBezierPath *workingLine;
    CGFloat x, y;
    NSPoint edgeOfDay, labelLineStart, labelLineEnd;
    NSRect labelFrame;
    
    NSDateFormatter *dateFormatter;
    NSString *dateString;
    NSUInteger labelMargin;
    
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

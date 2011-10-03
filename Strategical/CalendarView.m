//
//  CalendarView.m
//  Strategical
//
//  Created by Anders Aarsæther on 9/19/11.
//  Copyright 2011 Capasit. All rights reserved.
//

// TODO: add debug methods
// TODO: map paths to days
// TODO: connect to google calendar
// TODO: list events
// TODO: curved labels
// TODO: locale labels
// TODO: fullscreen view size
// TODO: solarized?
// TODO: different views for different resolutions

#import "CalendarView.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "NSBezierPath+Utility.h"
#import "YLFunTextView.h"
#import "YLBezierLayoutManager.h"
#import "YLTextStorage.h"

#include <math.h>

@implementation CalendarView

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) 
    {
        mouseHovering = YES;
        
        innerMaskPath = [[NSBezierPath alloc] init];
        outerMaskPath = [[NSBezierPath alloc] init];
        centerPath = [[NSBezierPath alloc] init];
        
        center.x = self.frame.size.width / 2;
        center.y = self.frame.size.height / 2;
        
        radiusCenter = 260;
        radiusDayStart = 290;
        radiusDayEnd = 350;
        radiusDayStartToday = 290;
        radiusDayEndToday = 350;
        radiusMonthStart = 270;
        radiusMonthEnd = 285;
        radiusMonthStartCurrent = 275;
        radiusMonthEndCurrent = 290;
        
        colorToday = [NSColor colorWithDeviceRed:(255/255.0f) green:(255/255.0f) blue:(255/255.0f) alpha:1.0f];
        colorThisMonth = [NSColor colorWithDeviceRed:(234/255.0f) green:(135/255.0f) blue:(69/255.0f) alpha:1.0f];
        colorStrokeThisMonth = [NSColor whiteColor];
        
        colorHover = [NSColor greenColor];
        colorWeekend = [NSColor whiteColor];
        
        colorDayPrimary = [NSColor colorWithDeviceRed:(222/255.0f) green:(222/255.0f) blue:(222/255.0f) alpha:1.0f];
        colorDaySecondary = [NSColor colorWithDeviceRed:(180/255.0f) green:(180/255.0f) blue:(180/255.0f) alpha:1.0f];
        
        colorMonthPrimary = [NSColor colorWithDeviceRed:(3/255.0f) green:(101/255.0f) blue:(100/255.0f) alpha:1.0f];
        colorMonthSecondary = [NSColor colorWithDeviceRed:(3/255.0f) green:(54/255.0f) blue:(73/255.0f) alpha:1.0f];

        colorCenter = [NSColor colorWithDeviceRed:(255/255.0f) green:(255/255.0f) blue:(255/255.0f) alpha:1.0f];
        
        dateLabel = [[NSTextField alloc] init];
        dateLabel.font = [NSFont fontWithName:@"Helvetica" size:10];
        
        [dateLabel setDrawsBackground:NO];
        [dateLabel setEditable:NO];
        [dateLabel setSelectable:NO];
        [dateLabel setBezeled:NO];
        [dateLabel setTextColor:[NSColor whiteColor]];
        
        labelMargin = 5; // px
        
        today = [NSDate date];
        components = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfYearCalendarUnit);
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        todayComponents = [calendar components:components fromDate:today];
        dateFormatter = [[NSDateFormatter alloc] init];
                
        dayOfYear = [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:today];
        weekOfYear = [calendar ordinalityOfUnit:NSWeekOfYearCalendarUnit inUnit:NSYearCalendarUnit forDate:today];
        monthOfYear = [calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:today];
        theYear = [todayComponents year];
        
        weeksInYear = [calendar rangeOfUnit:NSWeekOfYearCalendarUnit
                                      inUnit:NSYearCalendarUnit
                                     forDate:today].length;
        
        monthsInYear = [calendar rangeOfUnit:NSMonthCalendarUnit
                                       inUnit:NSYearCalendarUnit
                                      forDate:today].length;
        
        for (int i = 1; i <= monthsInYear; i++) 
        {
            todayComponents.month = i;
            NSDate *month = [calendar dateFromComponents:todayComponents];
            daysInYear += [calendar rangeOfUnit:NSDayCalendarUnit
                                          inUnit:NSMonthCalendarUnit
                                         forDate:month].length;
        }
    
        NSArray *dayPathsAndDates = [self createDayPathsAndDates];
        dayPaths = [dayPathsAndDates objectAtIndex:0];
        days = [dayPathsAndDates objectAtIndex:1];
        
        // weekPaths = [self createWeekPaths];
        monthPaths = [self createMonthPaths];
        
        
        [self createMonthLabels];
        //[self addSubview:monthLabels];
                    
        [self addSubview:dateLabel];
    }
    return self;
}

#pragma mark -
#pragma mark Path creation

- (NSArray *)createDayPathsAndDates
{        
    NSBezierPath *path;
    NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:daysInYear];
    NSMutableArray *dates = [[NSMutableArray alloc] initWithCapacity:daysInYear];
    
    NSCalendar *workCalendar = [NSCalendar currentCalendar];
    NSDate *workDate = [NSDate dateWithNaturalLanguageString:[NSString stringWithFormat:@"January 1, %ld", theYear]];
    NSDateComponents *work = [workCalendar components:components fromDate:workDate];
    NSDateComponents *increment = [[NSDateComponents alloc] init];
    NSUInteger workDayOfYear;
    
    while([work year] == theYear)
    {        
        workDayOfYear = [workCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:workDate];
        
        path = [self makeDayPath:workDayOfYear];
        
        [dates addObject:workDate];
        
        [increment setDay:1];
        
        workDate = [workCalendar dateByAddingComponents:increment toDate:workDate options:0];
        work = [workCalendar components:components fromDate:workDate];
        
        [path closePath];
        [paths addObject:path];
    } 
    
    return [[NSArray alloc] initWithObjects:paths, dates, nil];
}
/*
- (NSMutableArray *)createWeekPaths
{
    NSBezierPath *path;
    NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:weeksInYear];
    
    NSRange range;
    NSCalendar *workCalendar = [NSCalendar currentCalendar];
    NSDate *workDate = [NSDate dateWithNaturalLanguageString:[NSString stringWithFormat:@"January 1, %ld", theYear]];
    NSDateComponents *work = [workCalendar components:components fromDate:workDate];
    NSDateComponents *increment = [[NSDateComponents alloc] init];
    NSUInteger workDayOfYear;
    
    while([work year] == theYear) 
    {   
        workDayOfYear = [workCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:workDate];
        
        range = [workCalendar rangeOfUnit:NSDayCalendarUnit
                                   inUnit:NSWeekOfYearCalendarUnit
                                  forDate:[workCalendar dateFromComponents:work]];
        
        path = [self makePathFrom:workDayOfYear - 1 to:(workDayOfYear+range.length) - 1];
        
        [increment setWeek:1];
        
        workDate = [workCalendar dateByAddingComponents:increment toDate:workDate options:0];
        work = [workCalendar components:components fromDate:workDate];
        
        [path closePath];
        [paths addObject:path];
    }
    
    return paths;
}*/

- (NSMutableArray *)createMonthPaths
{
    NSBezierPath *path;
    NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:monthsInYear];
    
    NSRange range;
    NSCalendar *workCalendar = [NSCalendar currentCalendar];
    NSDate *workDate = [NSDate dateWithNaturalLanguageString:[NSString stringWithFormat:@"January 1, %ld", theYear]];
    NSDateComponents *work = [workCalendar components:components fromDate:workDate];
    NSDateComponents *increment = [[NSDateComponents alloc] init];
    NSUInteger workDayOfYear;
    
    while([work year] == theYear) 
    {   
        workDayOfYear = [workCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:workDate];
        
        range = [workCalendar rangeOfUnit:NSDayCalendarUnit
                                   inUnit:NSMonthCalendarUnit
                                  forDate:[workCalendar dateFromComponents:work]];
        
        path = [self makeMonthPathFrom:workDayOfYear to:(workDayOfYear+range.length)];
        
        [increment setMonth:1];
        
        workDate = [workCalendar dateByAddingComponents:increment toDate:workDate options:0];
        work = [workCalendar components:components fromDate:workDate];
        
        [path closePath];
        [paths addObject:path];
    }
    
    return paths;
}

- (void) createMonthLabels
{        
    YLTextStorage *storage[12]; 
    
    
    for(int i = 0; i < [monthPaths count]; i++)
    {   
        NSBezierPath *path = [monthPaths objectAtIndex:i]; 
        
        storage[i] = [YLTextStorage textStorage];
        monthLabels[i] = [[YLFunTextView alloc] initWithFrame:self.frame];
        
        monthLabels[i].layoutManager = [YLBezierLayoutManager layoutManagerWithBezierPath: [path bezierPathByStrippingRedundantElements]];
        
        NSMutableAttributedString *s = [[[NSMutableAttributedString alloc] initWithString: [NSString stringWithUTF8String: "January"]] autorelease];
        
        //[s setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Times" size: 32.0], NSFontAttributeName, nil] range: NSMakeRange(0, [s length])];
        
        [storage[i] loadText: s];
        monthLabels[i].textStorage = storage[i];
        
        [self addSubview:monthLabels[i]];
        
    }
}

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// DRAWING ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect
{   
    [self drawBackground:dirtyRect];
    [self drawDays:dirtyRect];
    [self drawMonths:dirtyRect];
}

////////////////////////////////////////////////////////////////////////////////
// Draw background

- (void) drawBackground:(NSRect)dirtyRect
{
    alpha = 0.1f;
    
    radius = (self.frame.size.width / 2);
    
    fill = [NSColor clearColor];
    frame = NSMakeRect(center.x - (radius / 2), center.y - (radius / 2), radius, radius);
    [outerMaskPath appendBezierPathWithOvalInRect: frame];
    [fill set];
    [outerMaskPath fill];
    
    radius = (self.frame.size.width / 2) - radiusDayEnd;
    fill = [NSColor clearColor];
    frame = NSMakeRect(center.x - (radius / 2), center.y - (radius / 2), radius, radius);
    [innerMaskPath appendBezierPathWithOvalInRect: frame];
    [fill set];
    [innerMaskPath fill];
    
    // Center ring
    
    radius = radiusCenter;
    
    fill = [colorCenter colorWithAlphaComponent:alpha];
    
    frame = NSMakeRect(center.x - radius, center.y - radius, radius * 2, radius * 2);
    
    [centerPath appendBezierPathWithOvalInRect: frame];
    
    [fill set];    
    [centerPath fill]; 
    [fill release];
}

////////////////////////////////////////////////////////////////////////////////
// Draw days

// TODO: cleanup
// TODO: dayPath creation on mouseclicked()?

- (void) drawDays:(NSRect)dirtyRect
{
    bool toggleDay = YES, toggleWeek = YES; 

    CGFloat units = daysInYear;
    NSDateComponents *work;
    
    lastWeek = 1;
            
    for(int i = 0; i < dayPaths.count; i++)
    {        
        work = [calendar components:components fromDate:[days objectAtIndex:i]];
                
        NSBezierPath *dayPath = (NSBezierPath *) [dayPaths objectAtIndex:i];  
        
        if((i+1) >= dayOfYear) {
            if(toggleWeek) {
                alpha = 0.7f;
            } else {
                alpha = 1.0f;
            }
        } else {
            alpha = 0.1f;
        }
        
        if(toggleDay) {
            fill = [colorDaySecondary colorWithAlphaComponent:alpha];
        } else {
            fill = [colorDayPrimary colorWithAlphaComponent:alpha];
        }
        
        toggleDay = !toggleDay;
        
        if([work weekOfYear] != lastWeek) {
            toggleWeek = !toggleWeek;
            lastWeek = [work weekOfYear];
        }
        
        // Saturday        
        /*
        if([work weekday] == 1 || [work weekday] == 7) 
            fill = [colorWeekend colorWithAlphaComponent:alpha];        
        */
        // Date is today

        if(!NSIntersectsRect(dirtyRect, dayPath.bounds))
            continue;
        
        if((i+1) == dayOfYear) 
        {
            fill = [NSColor whiteColor]; //  colorToday;

         
            
            [fill set];
            [dayPath fill];  
        } 
        else if (mouseClicked && [dayPath containsPoint:clickLocation])
        {            
            fill = [NSColor colorWithCalibratedRed:1.0f green:0.0f blue:0.0f alpha:alpha];
            
            [fill set];
            [dayPath fill];  
        } 
        else if (mouseHovering && [dayPath containsPoint:hoverLocation])
        {            
            workingLine = [NSBezierPath bezierPath];
            
            // i + 1.5 is center of day path
            
            x = cos(2*(M_PI) * ((i+1.5)/units)) * radiusDayEnd; 
            y = sin(2*(M_PI) * ((i+1.5)/units)) * radiusDayEnd; 
            
            edgeOfDay = NSMakePoint((self.frame.size.width / 2) + x, (self.frame.size.height / 2) + y);
            
            x = cos(2*(M_PI) * ((i+1.5)/units)) * (radiusDayEnd + 20); 
            y = sin(2*(M_PI) * ((i+1.5)/units)) * (radiusDayEnd + 20); 
            
            labelLineStart = NSMakePoint((self.frame.size.width / 2) + x, (self.frame.size.height / 2) + y);
                    
            [workingLine moveToPoint:edgeOfDay];            
            [workingLine lineToPoint:labelLineStart];
            
            [dateFormatter setDateFormat:@"EE dd MMM YYYY"];
            dateString = [dateFormatter stringFromDate:[days objectAtIndex:i]];                                                
            [dateLabel setStringValue:dateString];
            [dateLabel sizeToFit];
                        
            if(((self.frame.size.width / 2) + x) < (self.frame.size.width / 2)) // Left half
            {
                labelFrame = NSMakeRect(labelLineStart.x - dateLabel.frame.size.width, labelLineStart.y, dateLabel.frame.size.width, dateLabel.frame.size.height);
                [dateLabel setFrame:labelFrame];
                labelLineEnd = NSMakePoint(labelFrame.origin.x, labelFrame.origin.y);
            } 
            else // Right half
            {
                labelFrame = NSMakeRect(labelLineStart.x, labelLineStart.y, dateLabel.frame.size.width, dateLabel.frame.size.height);
                [dateLabel setFrame:labelFrame];
                labelLineEnd = NSMakePoint(labelFrame.origin.x + labelFrame.size.width, labelFrame.origin.y);
            }
                        
            [workingLine lineToPoint:labelLineEnd];
                        
            stroke = colorHover;
            
            [stroke set];
            [workingLine stroke];
            
            fill = colorHover;
            
            [fill set];
            [dayPath fill];  
        } 
        else 
        {
            [fill set];
            [dayPath fill];  
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Draw months

- (void) drawMonths:(NSRect)dirtyRect
{
    BOOL toggleMonth = YES;

    for(int i = 0; i < monthPaths.count; i++)
    {        
        NSBezierPath *monthPath = (NSBezierPath *) [monthPaths objectAtIndex:i];
        
        alpha = ((i+1) < monthOfYear) ? 0.1f : 1.0f;
        
        fill = toggleMonth ? 
            [colorMonthPrimary colorWithAlphaComponent:alpha] :
            [colorMonthSecondary colorWithAlphaComponent:alpha];
        
        toggleMonth = !toggleMonth;
                
        if((i+1) == monthOfYear) {
 
            fill = [colorThisMonth colorWithAlphaComponent:alpha];
            [fill set];
            
            [monthPath closePath];
            [monthPath fill];
            
        } else if([monthPath containsPoint:clickLocation]) {
            fill = [NSColor colorWithCalibratedRed:1.0f green:0.0f blue:0.0f alpha:alpha];            
        
            [fill set];

            [monthPath closePath];
            [monthPath fill];
            
        } else {
            [fill set];
            
            [monthPath closePath];
            [monthPath fill];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Draw weeks

- (void) drawWeeks:(NSRect)dirtyRect
{
    BOOL toggleWeek = YES;
    
    for(int i = 0; i < weekPaths.count; i++)
    {        
        NSBezierPath *weekPath = (NSBezierPath *) [weekPaths objectAtIndex:i];
        
        alpha = ((i+1) < weekOfYear) ? 0.1f : 1.0f;
        
        fill = toggleWeek ? 
        [NSColor colorWithCalibratedRed:0.7f green:1.0f blue:0.7f alpha:alpha] :
        [NSColor colorWithCalibratedRed:0.5f green:0.7f blue:0.5f alpha:alpha];
        
        toggleWeek = !toggleWeek;
        
        if((i+1) == weekOfYear)
            fill = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:0.0f alpha:alpha];
        
        if([weekPath containsPoint:clickLocation])
            fill = [NSColor colorWithCalibratedRed:1.0f green:0.0f blue:0.0f alpha:alpha];            
        
        [fill set];
        
        [weekPath closePath];
        [weekPath fill]; 
    }
}
 
- (NSBezierPath *)makeDayPath:(NSUInteger) i
{
    NSBezierPath *dayPath = [NSBezierPath bezierPath];
        
    float units = daysInYear;
    float offset = 0.1f;
    
    float start = ((i/units) * 360.0f) + offset;
    float stop = (((i+1)/units) * 360.0f) - offset;
    
    if(i != dayOfYear)
    {
        [dayPath appendBezierPathWithArcWithCenter:center 
                                            radius:radiusDayStart 
                                        startAngle:start 
                                          endAngle:stop];
        
        [dayPath appendBezierPathWithArcWithCenter:center 
                                            radius:radiusDayEnd
                                        startAngle:stop 
                                          endAngle:start 
                                         clockwise:YES];
        
    } else {
        [dayPath appendBezierPathWithArcWithCenter:center 
                                            radius:radiusDayStartToday
                                        startAngle:start 
                                          endAngle:stop];
        
        [dayPath appendBezierPathWithArcWithCenter:center 
                                            radius:radiusDayEndToday
                                        startAngle:stop 
                                          endAngle:start 
                                         clockwise:YES];
    }
        

    
    return dayPath;
}

- (NSBezierPath *)makeMonthPathFrom:(NSUInteger)fromDay to:(NSUInteger)toDay
{
    NSBezierPath *monthPath = [NSBezierPath bezierPath];
        
    float units = daysInYear;
    
    float start = ((fromDay/units) * 360.0f);
    float stop = ((toDay/units) * 360.0f);
    
    [monthPath appendBezierPathWithArcWithCenter:center radius:radiusMonthStart startAngle:start endAngle:stop];
    [monthPath appendBezierPathWithArcWithCenter:center radius:radiusMonthEnd startAngle:stop endAngle:start clockwise:YES];

    return monthPath;
}



////////////////////////////////////////////////////////////////////////////////
// Events

// TODO: dragging

#pragma mark -
#pragma mark Event handling

- (void)mouseDown:(NSEvent *)theEvent 
{    
    mouseClicked = YES;
    clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    // NSLog(@"-- (%0.f,%0.f)", clickLocation.x, clickLocation.y);
    [self setNeedsDisplay:YES];
    
}

- (void) mouseUp:(NSEvent *)theEvent
{
    mouseClicked = NO;
    [self setNeedsDisplay:YES];
}

- (void)updateTrackingAreas
{
    if(trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
        [trackingArea release];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingMouseMoved);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void) mouseMoved:(NSEvent *)theEvent
{
    hoverLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect;
    NSUInteger offset = 400;
    BOOL inDayPath = NO;
    
    for(int i = 0; i < dayPaths.count; i++)
    {
        NSBezierPath *path = [dayPaths objectAtIndex:i];
        
        if([path containsPoint:hoverLocation])
        {
            if(dayHovering == i)
                break;
            
            dayHovering = i;
            
            rect = [path bounds];
            
            rect.origin.x -= (offset / 2);
            rect.origin.y -= (offset / 2);
            rect.size.width += offset;
            rect.size.height += offset;
            
            [self setNeedsDisplayInRect:rect];
            inDayPath = YES;
            break;
        }
    }
    
    if(!inDayPath && (![outerMaskPath containsPoint:hoverLocation] || 
                       [innerMaskPath containsPoint:hoverLocation])) {
        [self setNeedsDisplay:YES];
    }
}

@end

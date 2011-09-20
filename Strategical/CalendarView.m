//
//  CalendarView.m
//  Strategical
//
//  Created by Anders Aarsæther on 9/19/11.
//  Copyright 2011 Capasit. All rights reserved.
//

#import "CalendarView.h"

#define DAYUNITS 365
#define MONTHUNITS 12

@implementation CalendarView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        days = [[NSMutableArray alloc] initWithCapacity:DAYUNITS];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    mouseHovering = YES;

    // TODO Move out into init...
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    dayOfYear = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:[NSDate date]];
    
    [self drawCalendar];
}


- (void) drawCalendar
{        
    NSColor *stroke, *fill; 
    
    bool toggleDay = YES;
    bool toggleMonth = YES;
    float alpha = 0.7f;
        
    fill = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:0.1f];
    
    NSBezierPath *backgroundPath = [NSBezierPath bezierPath];
    [backgroundPath setLineWidth:1];
    
    NSPoint center = { self.frame.size.width / 2, self.frame.size.height / 2 }; // TODO refactor
    
    int radius = 600;
    
    NSRect frame = NSMakeRect(center.x - (radius / 2), center.y - (radius / 2), radius, radius);
    
    
    
    /*
    frame.origin.x += 150;
    frame.origin.y += 150;
    frame.size.width -= 300;
    frame.size.height -= 300;
    */
    
    [backgroundPath appendBezierPathWithOvalInRect: frame];
    
    [fill set];    
    [backgroundPath fill];
    
    NSBezierPath *dayPath, *monthPath;
    
    ////////////////////////////////////////////////////////////////////////////
    // Draw months
    
    for (int i = 1; i <= MONTHUNITS; i++)
    {
        monthPath = [self makeMonthPath:i];
        
        fill = toggleMonth ? 
            [NSColor colorWithCalibratedRed:0.7f green:1.0f blue:0.7f alpha:alpha] :
            [NSColor colorWithCalibratedRed:0.5f green:0.7f blue:0.5f alpha:alpha];
        
        toggleMonth = !toggleMonth;
                
        if([monthPath containsPoint:clickLocation])
        {
            NSLog(@"++ %(%0.f,%0.f)", clickLocation.x, clickLocation.y);
            
            fill = [NSColor colorWithCalibratedRed:1.0f green:0.0f blue:0.0f alpha:alpha];
            
        }
        [monthPath closePath];
        [fill set];

        [monthPath fill];
    } 
    
    ////////////////////////////////////////////////////////////////////////////
    // Draw days
    
    for (int i = 1; i <= DAYUNITS; i++) 
    {        
        dayPath = [self makeDayPath:i];
                
        if(i >= dayOfYear) 
            alpha = 1.0f;
        else 
            alpha = 0.1f;
        
        if(toggleDay) {
            fill = toggleMonth ? 
            [NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:alpha] :
            [NSColor colorWithCalibratedRed:0.75f green:0.75f blue:0.75f alpha:alpha];
            toggleDay = NO;
        } else {
            fill = toggleMonth ? 
            [NSColor colorWithCalibratedRed:0.85f green:0.85f blue:0.85f alpha:alpha] :
            [NSColor colorWithCalibratedRed:0.70f green:0.70f blue:0.70f alpha:alpha];
            toggleDay = YES;
        }
        
        if(i % 7 == 0) {
            fill = toggleMonth ? 
            [NSColor colorWithCalibratedRed:0.7f green:0.8f blue:0.7f alpha:alpha] :
            [NSColor colorWithCalibratedRed:0.6f green:0.7f blue:0.6f alpha:alpha];
        }
        
        if(i == dayOfYear) {
            fill = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:alpha];
        }
                
        if(i % 30 == 0) {
            // toggleMonth = !toggleMonth;
        }
        
        alpha = 0.7f;        
        
        if(mouseClicked && [dayPath containsPoint:clickLocation])
        {
            NSLog(@"++ %(%0.f,%0.f)", clickLocation.x, clickLocation.y);

            fill = [NSColor colorWithCalibratedRed:1.0f green:0.0f blue:0.0f alpha:alpha];
            
        } else if (mouseHovering && [dayPath containsPoint:hoverLocation])
        {
            NSLog(@".. %(%0.f,%0.f)", hoverLocation.x, hoverLocation.y);
            
            fill = [NSColor colorWithCalibratedRed:0.7f green:0.5f blue:0.7f alpha:alpha];
            
        }
        
        [dayPath closePath];
        
        [fill set];
        [dayPath fill];     
    } 
}



- (NSBezierPath *)makeDayPath:(int) i
{
    NSBezierPath *dayPath = [NSBezierPath bezierPath];
    NSPoint center = { self.frame.size.width / 2, self.frame.size.height / 2 };  // TODO refactor
    
    float units = DAYUNITS;
    
    float start = ((i/units) * 360.0f) + 0.1f;
    float stop = (((i+1)/units) * 360.0f) - 0.1f;
    
    if(i != dayOfYear)
        [dayPath appendBezierPathWithArcWithCenter:center radius:330 startAngle:start endAngle:stop];
    else
        [dayPath appendBezierPathWithArcWithCenter:center radius:300 startAngle:start endAngle:stop];
        
    [dayPath appendBezierPathWithArcWithCenter:center radius:400 startAngle:stop endAngle:start clockwise:YES];
    
    return dayPath;
}

// TODO make real.

- (NSBezierPath *)makeMonthPath:(int) i
{
    NSBezierPath *monthPath = [NSBezierPath bezierPath];
    NSPoint center = { self.frame.size.width / 2, self.frame.size.height / 2 }; // TODO refactor
    
    float units = MONTHUNITS;
    
    float start = ((i/units) * 360.0f);
    float stop = (((i+1)/units) * 360.0f);
    
    [monthPath appendBezierPathWithArcWithCenter:center radius:320 startAngle:start endAngle:stop];
    [monthPath appendBezierPathWithArcWithCenter:center radius:330 startAngle:stop endAngle:start clockwise:YES];


    return monthPath;
}

#pragma mark -
#pragma mark Event handling

- (void)mouseDown:(NSEvent *)theEvent 
{    
    mouseClicked = YES;
    clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSLog(@"-- (%0.f,%0.f)", clickLocation.x, clickLocation.y);
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
    NSLog(@".. (%0.f,%0.f)", hoverLocation.x, hoverLocation.y);
    [self setNeedsDisplay:YES];
}

@end
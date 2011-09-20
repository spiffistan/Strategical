//
//  CalendarView.m
//  Strategical
//
//  Created by Anders Aarsæther on 9/19/11.
//  Copyright 2011 Capasit. All rights reserved.
//

#import "CalendarView.h"

#define DAYUNITS 365.0f

@implementation CalendarView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{    
    NSColor *stroke, *fill; 
    
    NSDate *now = [[NSDate alloc] init];
    
    stroke = [NSColor colorWithCalibratedRed:255.0f green:255.0f blue:255.0f alpha:0.8f];
    fill = [NSColor colorWithCalibratedRed:255.0f green:255.0f blue:255.0f alpha:0.5f];
    /*
    NSBezierPath *backgroundPath = [NSBezierPath bezierPath];
    [backgroundPath setLineWidth:1];
            
    
    NSRect frame = self.frame;
    
    frame.origin.x += 50;
    frame.origin.y += 50;
    frame.size.width -= 100;
    frame.size.height -= 100;
    
    [backgroundPath appendBezierPathWithOvalInRect: frame];
    
    [stroke set];
    [backgroundPath stroke];
    
    [fill set];    
    [backgroundPath fill];*/
            
    
    //[dayPath moveToPoint:center];
        
    NSBezierPath *dayPath;
    
    bool toggleDay = YES;
    bool toggleMonth = YES;
    float alpha = 0.7f;
    

    for (int i = 1; i < DAYUNITS; i+=1) 
    {        
        dayPath = [self makeDayPath:i];
        
        if(i > 200) 
            alpha = 0.1f;
        
        if(toggleDay) {
            fill = toggleMonth ? 
                [NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:alpha] :
                [NSColor colorWithCalibratedRed:0.75f green:0.75f blue:0.75f alpha:alpha];
            [fill set];
            toggleDay = NO;
        } else {
            fill = toggleMonth ? 
                [NSColor colorWithCalibratedRed:0.85f green:0.85f blue:0.85f alpha:alpha] :
                [NSColor colorWithCalibratedRed:0.70f green:0.70f blue:0.70f alpha:alpha];
            [fill set];
            toggleDay = YES;
        }
        
        if(i % 7 == 0) {
            fill = toggleMonth ? 
                [NSColor colorWithCalibratedRed:0.7f green:1.0f blue:0.7f alpha:alpha] :
                [NSColor colorWithCalibratedRed:0.5f green:0.7f blue:0.5f alpha:alpha];
            [fill set];
        }
        
        if(i % 30 == 0) {
            toggleMonth = !toggleMonth;
        }
        
        alpha = 0.7f;
        
        [dayPath closePath];
        [dayPath fill];

    }
    
        
//    [dayPath appendBezierPathWithArcFromPoint:NSMakePoint(350,350) toPoint:NSMakePoint(50,50) radius:30];
    
}

- (NSBezierPath *)makeDayPath:(int) i
{
    NSBezierPath *dayPath = [NSBezierPath bezierPath];
    NSPoint center = { self.frame.size.width / 2, self.frame.size.height / 2 };
    
    float start = ((i/DAYUNITS) * 360.f);
    float stop = (((i+1)/DAYUNITS) * 360.0f);
    
    [dayPath appendBezierPathWithArcWithCenter:center radius:330 startAngle:start endAngle:stop];
    [dayPath appendBezierPathWithArcWithCenter:center radius:400 startAngle:stop endAngle:start clockwise:YES];
    
    return dayPath;
}

@end

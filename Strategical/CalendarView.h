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
    NSUInteger dayOfYear;
    
    NSMutableArray *dayPaths;
}



@end

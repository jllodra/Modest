//
//  MDEqMeterView.m
//  Modest
//
//  Created by Josep Llodrà on 26/03/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import "MDEqMeterView.h"

// #define MAX(x,y) (((x) < (y)) ? (y) : (x))

@implementation MDEqMeterView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        sf = NULL;
    }
    return self;
}

- (void) setS:(float*)spec {
    sf = spec;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    // [color set];
    // NSRectFill(dirtyRect);

    if(sf != NULL) {
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [NSColor redColor].CGColor);
        CGContextSetFillColorWithColor(context, [NSColor orangeColor].CGColor);

        for (int i = 0; i < 64; i++) {
            CGRect rectangle = CGRectMake(2+i*([self frame].size.width/64), -1, 2, MIN(sf[i]*1480, [self frame].size.height));
            
            CGContextAddRect(context, rectangle);
            
            //CGContextStrokePath(context);
            CGContextFillRect(context, rectangle);
            CGContextStrokeRect(context, rectangle);
        }
    }
    
}

@end

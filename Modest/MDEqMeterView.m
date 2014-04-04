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

- (void)awakeFromNib {
    peak = (float*)malloc(sizeof(float)*64);
    memset(peak, 0, sizeof(float)*64);
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
            if(sf[i] > peak[i]) {
                peak[i] = sf[i];
            } else {
                peak[i] = peak[i] - 0.018;
            }
            CGRect peakrect = CGRectMake(
                                          2+i*([self frame].size.width/64),
                                          MIN(peak[i]*2/*scale*/*[self frame].size.height, [self frame].size.height)-2,
                                          2,
                                          1
                                          );
            CGRect bar = CGRectMake(
                                    2+i*([self frame].size.width/64),
                                    -1,
                                    2,
                                    MIN(sf[i]*2/*scale*/*[self frame].size.height, [self frame].size.height)
                                    );

            
            //CGRect rectangle = CGRectMake(2+i*([self frame].size.width/64), -1, 2, sf[i]*[self frame].size.height);

            //CGRect rectangle = CGRectMake(2+i*([self frame].size.width/64), -1, 2, MIN(sf[i]*1480, [self frame].size.height));
            
            CGContextAddRect(context, bar);
            CGContextFillRect(context, bar);
            CGContextStrokeRect(context, bar);

            CGContextAddRect(context, peakrect);
            CGContextFillRect(context, peakrect);
            CGContextStrokeRect(context, peakrect);
        }
    }
    
}

@end

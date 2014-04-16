//
//  MDEqMeterView.m
//  Modest
//
//  Created by Josep Llodrà on 26/03/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import "MDEqMeterView.h"

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
    if(sf==NULL)
        sf = spec;
}

- (void)drawRect:(NSRect)dirtyRect
{
    static CGFloat width;
    static CGFloat height;
    CGRect peakrect;
    CGRect bar;

    width = self.frame.size.width;
    height = self.frame.size.height;
    
    [super drawRect:dirtyRect];
    
    if(sf != NULL) {

        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [NSColor redColor].CGColor);
        CGContextSetFillColorWithColor(context, [NSColor orangeColor].CGColor);

        for (int i = 0; i < 64; i++) {
            peak[i] = (sf[i] > peak[i]) ? sf[i] : peak[i] - 0.02;

            peakrect = CGRectMake(
                                          2+i*(width/64),
                                          MIN(peak[i]*2*height, height)-2,
                                          2,
                                          1
                                          );
            bar = CGRectMake(
                                    2+i*(width/64),
                                    -1,
                                    2,
                                    MIN(sf[i]*2*height, height)
                                    );
            
            
            CGContextFillRect(context, bar);
            CGContextStrokeRect(context, bar);

            CGContextFillRect(context, peakrect);
            CGContextStrokeRect(context, peakrect);
        }

    }
    
}

@end

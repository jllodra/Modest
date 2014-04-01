//
//  MDEqMeterView.h
//  Modest
//
//  Created by Josep Llodrà on 26/03/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MDEqMeterView : NSView {
    float *sf;
}

- (void) setS:(float*)spec;

@end

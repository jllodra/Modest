//
//  MDAppDelegate.h
//  Modest
//
//  Created by Josep Llodrà Grimalt on 22/03/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDEqMeterView.h"
#import "MDSongsTableView.h"

@interface MDAppDelegate : NSObject <NSApplicationDelegate> {
    __weak MDEqMeterView *eqMeterView;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet MDEqMeterView *eqMeterView;
@property (weak) IBOutlet MDSongsTableView *songsTableView;
@property (weak) IBOutlet NSTextField *statusText;
@property (weak) IBOutlet NSButton *playPauseButton;

- (void)playSong:(NSURL*)fileNSUrl;

@end

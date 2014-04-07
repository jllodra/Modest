//
//  MDAppDelegate.m
//  Modest
//
//  Created by Josep Llodrà Grimalt on 22/03/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import "MDAppDelegate.h"
#import "MDAudioManager.h"

@interface MDAppDelegate () {
    MDAudioManager *audioManager;
    NSThread *audioManagerThread;
    NSOpenPanel *openPanel;
}
@end

@implementation MDAppDelegate
@synthesize eqMeterView;
@synthesize songsTableView;
@synthesize statusText;
@synthesize playPauseButton;
@synthesize infoWindowController;

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ((NSView *)self.window.contentView).wantsLayer = YES;
    // audio thread
    audioManager = [[MDAudioManager alloc] init];
    audioManagerThread = [[NSThread alloc] initWithTarget:audioManager
                                                 selector:@selector(setUp)
                                                   object:nil];
    [audioManagerThread start];
    // init file picker
    openPanel = [NSOpenPanel openPanel];

}

- (IBAction)addButton:(NSButton *)sender {
    [openPanel setAllowedFileTypes:@[@"it", @"xm", @"s3m", @"mod"]];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    //[openDlg setDirectoryURL:@""];
    
    if([openPanel runModal] == NSOKButton) {
        NSArray* files = [openPanel URLs];
        for(int i = 0; i < [files count]; i++) {
            NSURL *fileNSUrl = [files objectAtIndex:i];
            [statusText setStringValue:[fileNSUrl path]];
            [audioManager performSelector:@selector(loadSongAndPlay:) onThread:audioManagerThread withObject:fileNSUrl waitUntilDone:YES];
            bool isPlaying = [[[audioManagerThread threadDictionary] valueForKey:@"isPlaying"] boolValue];
            if(isPlaying) {
                self.playPauseButton.title = @"Pause";
            } else {
                self.playPauseButton.title = @"Play";
            }
        }
    }
}

- (IBAction)playPauseButton:(NSButton *)sender {
    bool isPlaying = [[[audioManagerThread threadDictionary] valueForKey:@"isPlaying"] boolValue];
    
    if(isPlaying) {
        [audioManager performSelector:@selector(pause) onThread:audioManagerThread withObject:nil waitUntilDone:NO];
        self.playPauseButton.title = @"Play";
    } else {
        [audioManager performSelector:@selector(play) onThread:audioManagerThread withObject:nil waitUntilDone:NO];
        self.playPauseButton.title = @"Pause";
    }
}

- (IBAction)stopButton:(NSButton *)sender {
    [audioManager performSelector:@selector(stop) onThread:audioManagerThread withObject:nil waitUntilDone:NO];
    self.playPauseButton.title = @"Play";
}

- (IBAction)infoButton:(NSButton *)sender {
    bool isPlaying = [[[audioManagerThread threadDictionary] valueForKey:@"isPlaying"] boolValue];
    if(isPlaying) {
        if (self.infoWindowController == nil) {
            self.infoWindowController = [[MDInfoWindowController alloc] initWithWindowNibName:@"Info"];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_infoWindowWillClose) name:NSWindowWillCloseNotification object:nil];
        }
        [self.infoWindowController showWindow:sender];
        [[self.infoWindowController textView] setString:[[audioManagerThread threadDictionary] valueForKey:@"infoText"]];
    }
}

- (void)_infoWindowWillClose {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:nil];
     self.infoWindowController = nil;
}

- (void)playSong:(NSURL*)fileNSUrl {
    [audioManager performSelector:@selector(loadSong:) onThread:audioManagerThread withObject:fileNSUrl waitUntilDone:YES];
    [audioManager performSelector:@selector(play) onThread:audioManagerThread withObject:nil waitUntilDone:NO];
    [statusText setStringValue:[fileNSUrl path]];
    self.playPauseButton.title = @"Pause";
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[audioManagerThread threadDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"exitNow"];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        [self.window orderFront:self];
    }
    else {
        [self.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}

@end

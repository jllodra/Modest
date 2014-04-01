//
//  MDSongsTableView.h
//  Modest
//
//  Created by Josep Llodrà on 01/04/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MDSongsTableView : NSTableView <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) NSMutableArray *songs;

- (void)addSong:(NSURL*)fileNSUrl songName:(NSString*)songName;

@end

//
//  MDSongsTableView.m
//  Modest
//
//  Created by Josep Llodrà on 01/04/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import "MDSongsTableView.h"
#import "MDAppDelegate.h"

@implementation MDSongsTableView
@synthesize songs;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // self.wantsLayer = YES;
    }
    return self;
}

- (void)awakeFromNib {
    if(self.songs == nil) {
        self.songs = [[NSMutableArray alloc]initWithCapacity:100];
    }
    [self setDelegate:self];
    [self setDataSource:self];
    [self setDoubleAction:@selector(doubleClick)];
}

- (void)addSong:(NSURL*)fileNSUrl songName:(NSString*)songName {
    NSString *song_name = songName;
    NSURL *file_nsurl = fileNSUrl;
    [self.songs addObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                      file_nsurl, @"fileNSUrl",
                      [[file_nsurl absoluteString] lastPathComponent], @"filename",
                      song_name, @"songname",
                      nil]];
    [self reloadData];
}

- (void)doubleClick {
    NSUInteger clicked_row_number = [self clickedRow];
    if(clicked_row_number < [self.songs count]) {
        MDAppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        [delegate playSong:[[self.songs objectAtIndex:clicked_row_number] valueForKey:@"fileNSUrl"]];
    }
}


- (void)keyDown:(NSEvent *)theEvent {
    // prevent beeping
}

- (void)keyUp:(NSEvent *)theEvent {
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter) {
        if((self.selectedRow != -1) && [self selectedRow] < [self.songs count]) {
            [songs removeObjectAtIndex:self.selectedRow];
            [self reloadData];
        }
    }
    [super keyUp:theEvent];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [songs count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {

    NSString *identifier = [tableColumn identifier];
    
    if([identifier isEqualToString:@"File"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = [[songs objectAtIndex:row] objectForKey:@"filename"];
        return cellView;
    } else if ([identifier isEqualToString:@"Song"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = [[songs objectAtIndex:row] objectForKey:@"songname"];
        return cellView;
    } else {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    
    return nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    // Drawing code here.
}

@end

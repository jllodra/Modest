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
        //self.wantsLayer = YES;
    }
    return self;
}

- (void)awakeFromNib {
    if(self.songs == nil) {
        self.songs = [[NSMutableArray alloc]initWithCapacity:100];
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType , nil]];
        [self setDelegate:self];
        [self setDataSource:self];
        [self setDoubleAction:@selector(doubleClick)];
    }
}

- (void)addSong:(NSURL*)fileNSUrl songName:(NSString*)songName {
    NSString *song_name = songName;
    NSURL *file_nsurl = fileNSUrl;
    [self.songs addObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                      file_nsurl, @"fileNSUrl",
                      [[[file_nsurl absoluteString] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"filename",
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

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    // Drag and drop support
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:self];
    [pboard setData:data forType:NSFilenamesPboardType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if(dropOperation == NSTableViewDropOn)
        return NSDragOperationNone;
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pboard = [info draggingPasteboard];

    if(nil == [info draggingSource]) {
        // from outside
        NSArray *fileNames = [pboard propertyListForType:NSFilenamesPboardType];
        for(NSString *file in fileNames) {
            NSLog(@"%@", file);
            if([file hasSuffix:@".it"] || [file hasSuffix:@".xm"] || [file hasSuffix:@".s3m"] || [file hasSuffix:@".mod"]) {
                NSURL *file_nsurl = [NSURL fileURLWithPath:file];
                [self.songs insertObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                       file_nsurl, @"fileNSUrl",
                                       [[[file_nsurl absoluteString] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"filename",
                                       @"", @"songname",
                                       nil]
                                 atIndex:row];
            }
        }
        [self reloadData];
    } else if (self == [info draggingSource]) {
        // from inside
        NSData* rowData = [pboard dataForType:NSURLPboardType];
        NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
        NSInteger dragRow = [rowIndexes firstIndex];
        
        if(dragRow > row) {
            row++;
        }
        id song = [self.songs objectAtIndex:dragRow];
        [self.songs removeObjectAtIndex:dragRow];
        [self.songs insertObject:song atIndex:row-1];
        
        [self reloadData];
    }
    
    return YES;
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

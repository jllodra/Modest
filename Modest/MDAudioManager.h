//
//  MDAudioManager.h
//  Modest
//
//  Created by Josep Llodrà Grimalt on 23/03/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDAppDelegate.h"
#import "fmod.hpp"
@interface MDAudioManager : NSObject {
    //FMOD::System *system;
}

@property (strong) NSMutableDictionary *threadDict;

- (void)setUp;
- (void)loadSong:(NSURL*)file;
- (void)loadSongAndPlay:(NSURL*)file;
- (void)play;
- (void)stop;
@end

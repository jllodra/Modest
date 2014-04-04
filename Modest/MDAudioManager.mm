//
//  MDAudioManager.m
//  Modest
//
//  Created by Josep Llodrà Grimalt on 23/03/14.
//  Copyright (c) 2014 Atlantis of code. All rights reserved.
//

#import "MDAudioManager.h"
#import "fmod.hpp"

@interface MDAudioManager () {
    FMOD::System    *system;
    FMOD::Sound     *sound;
    FMOD::Channel   *channel;
    unsigned int    version;
    void            *extradriverdata;
    
    BOOL            exitNow;
    
    MDAppDelegate   *delegate;
}

@end

@implementation MDAudioManager
@synthesize threadDict;

- (void)setUp:(MDAppDelegate*)appDelegate
{
    @autoreleasepool {

        delegate = appDelegate;
        exitNow = NO;
        extradriverdata = NULL;
        system = NULL;
        sound = NULL;
        channel = NULL;

        bool isPlaying;
        int sampleSize = 64;
        float *spec, *specLeft, *specRight;
        spec = new float[sampleSize];
        specLeft = new float[sampleSize];
        specRight = new float[sampleSize];
        float maxpow;

        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        threadDict = [[NSThread currentThread] threadDictionary];
        [threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"exitNow"];
        [threadDict setValue:[NSNumber numberWithBool:NO] forKey:@"isPlaying"];

        [self initFMOD];
        
        do {
            @autoreleasepool {
                //[runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.055]];
            }
            //usleep(10000);
            system->update();
            
            channel->isPlaying(&isPlaying);
            if(isPlaying) {
                // Get spectrum for left and right stereo channels
                channel->getSpectrum(specLeft, sampleSize, 0, FMOD_DSP_FFT_WINDOW_RECT);
                channel->getSpectrum(specRight, sampleSize, 1, FMOD_DSP_FFT_WINDOW_RECT);

                //NSMutableArray *spectrum = [[NSMutableArray alloc] initWithCapacity:65];
                maxpow = 0;
                for (int i = 0; i < sampleSize; i++) {
                    spec[i] = (specLeft[i] + specRight[i]) / 2;
                    maxpow = (spec[i] > maxpow) ? spec[i] : maxpow;
                    //[spectrum addObject:[NSNumber numberWithFloat:spec[i]]];
                }
                for (int i = 0; i < sampleSize; i++) {
                    spec[i] = spec[i] / maxpow;
                }
                //printf("%f\n",avgpow);
                //printf("%f\n", spec[0]);
                //float red = spec[0];
                //float green = spec[0];
                //float blue = spec[0];
                
                //NSColor* myColor = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];

                //[[appDelegate eqMeterView] setSpectrum:spectrum];
                [[appDelegate eqMeterView] setS:spec];
                //[[appDelegate eqMeterView] setColor:myColor];
                [[appDelegate eqMeterView] setNeedsDisplay:YES];
            }
            exitNow = [[threadDict valueForKey:@"exitNow"] boolValue];
        } while(!exitNow);
        
        delete [] spec;
        delete [] specLeft;
        delete [] specRight;
        
        channel->stop();
        sound->release();
        system->release();
        
        [[self threadDict] setValue:NULL];
        
        NSLog(@"Audio Manager Thread exiting");
    }
}

- (void)initFMOD {
    NSLog(@"Configuring FMOD");
    
    if(FMOD::System_Create(&system) != FMOD_OK) {
        NSLog(@"Error creating system");
    }
    
    if(system->getVersion(&version) != FMOD_OK) {
        NSLog(@"Error getting version");
    }
    
    if (version < FMOD_VERSION) {
        NSLog(@"FMOD lib version %08x doesn't match header version %08x", version, FMOD_VERSION);
    }
    
    if(system->init(1, FMOD_INIT_NORMAL, extradriverdata) != FMOD_OK) {
        NSLog(@"Error initializating FMOD");
    }
}

- (void)loadSong:(NSURL*)file
{
    NSLog(@"loadSong");
    
    channel->stop();
    sound->release();
    [threadDict setValue:[NSNumber numberWithBool:NO] forKey:@"isPlaying"];

    system->createSound([[file path] UTF8String], FMOD_DEFAULT, 0, &sound);
}

- (void)loadSongAndPlay:(NSURL*)file
{
    NSLog(@"loadSongAndPlay");
    
    channel->stop();
    sound->release();
    [threadDict setValue:[NSNumber numberWithBool:NO] forKey:@"isPlaying"];
   
    //system->createSound([[file path] UTF8String], FMOD_DEFAULT | FMOD_SOFTWARE, 0, &sound);
    system->createSound([[file path] UTF8String], FMOD_DEFAULT, 0, &sound);
    system->playSound(FMOD_CHANNEL_FREE, sound, false, &channel);
    [threadDict setValue:[NSNumber numberWithBool:YES] forKey:@"isPlaying"];

    char name[100];
    sound->getName(name, 100);
    NSString *songname = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    [delegate.songsTableView addSong:file songName:songname];
    
    FMOD_TAG tag;
    int numtags, numtagsupdated, count;
    
    sound->getNumTags(&numtags, &numtagsupdated);
    
    for (count=0; count < numtags; count++) {
        sound->getTag(0, count, &tag);
        if (tag.datatype == FMOD_TAGDATATYPE_STRING)
        {
            printf("%s = %s (%d bytes)\n", tag.name, tag.data, tag.datalen);
        }
        else if (tag.datatype == FMOD_TAGDATATYPE_INT) {
            printf("%s = %02d", tag.name, ((unsigned int *)tag.data)[0]);
        } else {
            
            printf("%s = binary (%d bytes)\n", tag.name, tag.datalen);
        }
    }
}


- (void)play
{
    NSLog(@"play");
    bool isPaused;
    channel->getPaused(&isPaused);
    if(isPaused) {
        channel->setPaused(false);
    } else {
        system->playSound(FMOD_CHANNEL_FREE, sound, false, &channel);
    }
    [threadDict setValue:[NSNumber numberWithBool:YES] forKey:@"isPlaying"];
}

- (void)stop
{
    NSLog(@"stop");
    channel->stop();
    [threadDict setValue:[NSNumber numberWithBool:NO] forKey:@"isPlaying"];
}

- (void)pause
{
    NSLog(@"pause");
    channel->setPaused(true);
    [threadDict setValue:[NSNumber numberWithBool:NO] forKey:@"isPlaying"];
}

@end

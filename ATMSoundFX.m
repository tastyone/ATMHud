/*
 *  ATMSoundFX.m
 *  ATMHud
 *
 *  Created by Marcel Müller on 2011-03-01.
 *  Copyright (c) 2010-2011, Marcel Müller (atomcraft)
 *  All rights reserved.
 *
 *	https://github.com/atomton/ATMHud
 */

#import "ATMSoundFX.h"

@implementation ATMSoundFX

+ (id)soundEffectWithContentsOfFile:(NSString *)aPath {
    if (aPath) {
#if __has_feature(objc_arc)
        return [[ATMSoundFX alloc] initWithContentsOfFile:aPath];
#else
        return [[[ATMSoundFX alloc] initWithContentsOfFile:aPath] autorelease];
#endif
    }
    return nil;
}

- (id)initWithContentsOfFile:(NSString *)path {
    self = [super init];
    
    if (self != nil) {
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        
        if (aFileURL != nil)  {
            SystemSoundID aSoundID;
#if __has_feature(objc_arc)
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL, &aSoundID);
#else
            OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &aSoundID);
#endif
            
            if (error == kAudioServicesNoError) {
                _soundID = aSoundID;
            } else {
#if __has_feature(objc_arc)
                self = nil;
#else
                [self release], self = nil;
#endif
            }
        } else {
#if __has_feature(objc_arc)
            self = nil;
#else
            [self release], self = nil;
#endif
        }
    }
    return self;
}

-(void)dealloc {
    AudioServicesDisposeSystemSoundID(_soundID);
#if __has_feature(objc_arc)
#else
    [super dealloc];
#endif
}

-(void)play {
    AudioServicesPlaySystemSound(_soundID);
}

@end
//
//  OpenALManager.h
//  Particles
//
//  Created by Baptiste Bohelay on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundObject : NSObject
{
	ALuint m_id;
	ALuint m_bufferID;
	float m_pitchVar;
    BOOL  m_loop;
    BOOL m_isLoaded;
    BOOL m_isPermanent;
    NSString * m_fileExt;
}

@property ALuint m_id;
@property ALuint m_bufferID;
@property float m_pitchVar;
@property BOOL m_isLoaded;
@property BOOL m_loop;
@property BOOL m_isPermanent;
@property (nonatomic, retain) NSString * m_fileExt;

-(id)initWithExt:(NSString *)a_fileExt
        pitchVar:(float)a_pitchVar
            loop:(BOOL)a_loop
       permanent:(BOOL)a_permanent;

-(void)Unload;

@end


@interface FadingObject : NSObject
{
	NSUInteger m_id;
	float m_volumeEnd;
	ALfloat m_volumeInit;
	NSTimeInterval m_duration;
	NSTimeInterval m_currentTime;
	BOOL m_stopEnd;
}

@property NSUInteger m_id;
@property float m_volumeEnd;
@property ALfloat m_volumeInit;
@property NSTimeInterval m_duration;
@property NSTimeInterval m_currentTime;
@property BOOL m_stopEnd;
@end


@interface OpenALManager : NSObject 
{	
	ALCcontext* mContext; // stores the context (the 'air')
	ALCdevice* mDevice; // stores the device
	//NSMutableArray * bufferStorageArray; // stores the buffer ids from openAL
	NSMutableArray * m_fadeArray;
	NSMutableDictionary * soundDictionary; // stores our soundkeys
	int m_numToFade;
}

// if you want to access directly the buffers or our sound dictionary
@property (nonatomic, retain) NSMutableDictionary * soundDictionary;

- (id)	 init; // init once
- (bool) initOpenAL; // no need to make it public, but I post it here to show you which methods we need. initOpenAL will be called within init process once.
- (void) playSoundWithKey:(NSString*)soundKey Volume:(ALfloat)a_volume; // play a sound by name
- (void) SetVolumeWithKey:(NSString*)soundKey Volume:(ALfloat)a_volume;
- (void) SetPitchWithKey:(NSString*)soundKey Pitch:(ALfloat)a_pitch;
- (void) stopSoundWithKey:(NSString*)soundKey; // stop a sound by name
- (void) StopAll;
- (bool) isPlayingSoundWithKey:(NSString *) soundKey; // check if sound is playing by name
- (void) rewindSoundWithKey:(NSString *) soundKey; // rewind a sound by name so its playing again
// delete a key, unload it.
-(BOOL)DeleteKey:(NSString * )a_soundKey;
// add metadata for a key.
-(BOOL)AddMetadata:(NSString *)_soundKey 
           fileExt:(NSString *)a_fileExt
              loop:(bool)loops 
          pitchVar:(float)a_pitchVar;

-(BOOL)AddMetadata:(NSString *)a_soundKey 
           fileExt:(NSString *)a_fileExt
              loop:(bool)loops;

-(BOOL)AddMetadata:(NSString *)a_soundKey 
           fileExt:(NSString *)a_fileExt
              loop:(bool)loops 
          pitchVar:(float)a_pitchVar
         permanent:(BOOL)a_permanent;
// 
-(bool) loadSoundWithKey:(NSString *)a_soundKey;
-(BOOL)SetNewList:(NSArray *)a_list;
-(void)FadeWithKey:(NSString *)a_soundKey duration:(float)a_duration volume:(float)a_volume stopEnd:(BOOL)a_stopEnd;
-(void)UpdateFading:(NSTimeInterval)a_timeInterval;
-(void)RemoveFadingId:(unsigned int)a_id;
-(void)ReleaseFading;

+ (OpenALManager*)sharedOpenALManager; // access to our instance
- (void) shutdownOpenALManager;

@end

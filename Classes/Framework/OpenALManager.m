//
//  OpenALManager.m
//  Particles
//
//  Created by Baptiste Bohelay on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenALManager.h"
#import "OpenALSupport.h"
#import "MathTools.h"

#define SOUND_ENABLE YES

@implementation SoundObject

@synthesize m_id;
@synthesize m_bufferID;
@synthesize m_pitchVar;
@synthesize m_isLoaded;
@synthesize m_loop;
@synthesize m_fileExt;
@synthesize m_isPermanent;

-(id)initWithExt:(NSString *)a_fileExt
       pitchVar:(float)a_pitchVar
            loop:(BOOL)a_loop
       permanent:(BOOL)a_permanent
{
    m_isPermanent = a_permanent;
    m_id = -1;
    m_bufferID = -1;
	m_pitchVar = a_pitchVar;
    m_loop = a_loop;
    m_isLoaded = NO;
    m_fileExt = a_fileExt;
	return [super init];
}

-(void)Unload
{
    ALenum state;

    alGetSourcei(m_id, AL_SOURCE_STATE, &state);

    if(state != AL_STOPPED)
    {
        alSourceStop(m_id);
    }
    alDeleteSources(1, &m_id);
    alDeleteBuffers(1, &m_bufferID);
    m_isLoaded = NO;
    m_id = 0;
    m_id = 0;
    
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error play sound: %x\n", error);
		exit(1);
	}
}

@end

@implementation FadingObject

@synthesize m_id;
@synthesize m_volumeEnd;
@synthesize m_volumeInit;
@synthesize m_duration;
@synthesize m_currentTime;
@synthesize m_stopEnd;

@end

@implementation OpenALManager

@synthesize soundDictionary;

static OpenALManager *sharedOpenALManager = nil;

- (void) shutdownOpenALManager {
	@synchronized(self) {
        if (sharedOpenALManager != nil) {
			[self dealloc]; // assignment not done here
        }
    }
}

+ (OpenALManager*)sharedOpenALManager {
	
    @synchronized(self) {
        if (sharedOpenALManager == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedOpenALManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedOpenALManager == nil) {
            sharedOpenALManager = [super allocWithZone:zone];
            return sharedOpenALManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
	
	return UINT_MAX;  //denotes an object that cannot be released
}

-(oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

// seek in audio file for the property 'size'
// return the size in bytes
-(UInt32)audioFileSize:(AudioFileID)fileDescriptor
{
	UInt64 outDataSize = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
	if(result != 0) NSLog(@"cannot find file size");
	return (UInt32)outDataSize;
}

// start up openAL
-(bool) initOpenAL
{
	// Initialization
	mDevice = alcOpenDevice(NULL); // select the "preferred device"
	if (mDevice) {
		// use the device to make a context
		mContext=alcCreateContext(mDevice,NULL);
		// set my context to the currently active one
		alcMakeContextCurrent(mContext);
		return true;
	}
	return false;
}

-(id) init 
{
	if (self = [super init] ) {
		if ([self initOpenAL]) 
        {
			self.soundDictionary = [[[NSMutableDictionary alloc]init]autorelease];
			m_fadeArray = [[NSMutableArray alloc]init];	
		}
		return self;
	}
	[self release];
	return nil;
}

-(void) dealloc 
{
	// delete the sources
    SoundObject * l_soundObject;
    NSArray * l_dictionaryKeyList = [soundDictionary allKeys];
    ALuint l_sourceID;
    ALuint l_bufferID;
	for (int i = 0; i < [l_dictionaryKeyList count]; i++) 
    {
        l_soundObject = [soundDictionary objectForKey:[l_dictionaryKeyList objectAtIndex:i]];
        l_sourceID = l_soundObject.m_id;
        l_bufferID = l_soundObject.m_bufferID;
		alDeleteSources(1, &l_sourceID);
        alDeleteBuffers(1, &l_bufferID);
	}

	self.soundDictionary=nil;
	
	// destroy the context
	alcDestroyContext(mContext);
	// close the device
	alcCloseDevice(mDevice);
	[l_dictionaryKeyList release];
	[super dealloc];
}

// the main method: grab the sound ID from the library
// and start the source playing
- (void)playSoundWithKey:(NSString*)soundKey Volume:(ALfloat)a_volume
{
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error play sound: %x\n", error);
		exit(1);
	}
    
    SoundObject * l_soundObject = [soundDictionary objectForKey:soundKey];
    if (l_soundObject == nil) return;
    if(!l_soundObject.m_isLoaded)
    {
        printf("You must load the sound before you play it.\n");
        return;
    }
    NSUInteger sourceID = [l_soundObject m_id];
    float l_pitch = 1.f + myRandom() * [l_soundObject m_pitchVar];
    alSourcef(sourceID, AL_GAIN, a_volume); 
    alSourcef(sourceID, AL_PITCH, l_pitch); 	
    alSourcePlay(sourceID);
    
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error play sound: %x\n", error);
		exit(1);
	}
}

- (void)SetVolumeWithKey:(NSString*)soundKey Volume:(ALfloat)a_volume
{
    SoundObject * l_soundObject = [soundDictionary objectForKey:soundKey];
    if (l_soundObject == nil) return;
    if(!l_soundObject.m_isLoaded)
    {
//        printf("You must load the sound before you SetVolumeWithKey.\n");
        return;
    }
    NSUInteger sourceID = [l_soundObject m_id];
    alSourcef(sourceID, AL_GAIN, a_volume); 
    
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error volume sound: %x\n", error);
		exit(1);
	}
}

- (void)SetPitchWithKey:(NSString*)soundKey Pitch:(ALfloat)a_pitch
{
	SoundObject * l_soundObject = [soundDictionary objectForKey:soundKey];
	if (l_soundObject == nil) return;
    if(!l_soundObject.m_isLoaded)
    {
        printf("You must load the sound before you SetPitchWithKey.\n");
        return;
    }
	NSUInteger sourceID = [l_soundObject m_id];
	alSourcef(sourceID, AL_PITCH, a_pitch); 
    
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error pitch sound: %x\n", error);
		exit(1);
	}
}

- (void)stopSoundWithKey:(NSString*)soundKey
{
	SoundObject * l_soundObject = [soundDictionary objectForKey:soundKey];
	if (l_soundObject == nil) return;
    if(!l_soundObject.m_isLoaded)
    {
        printf("You must load the sound before you stopSoundWithKey.\n");
        return;
    }
    
	NSUInteger sourceID = [l_soundObject m_id];
	alSourceStop(sourceID);
    
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error stop sound: %x\n", error);
		exit(1);
	}
}

-(void)StopAll
{
	NSArray * l_array = [soundDictionary allKeys];
	SoundObject * l_soundObject;
	NSUInteger sourceID;
	for(int i = [l_array count] - 1; i >= 0; i--)
	{
		l_soundObject = [soundDictionary objectForKey:[l_array objectAtIndex:i]];
		if (l_soundObject == nil) return;
        if(!l_soundObject.m_isLoaded)
        {
            continue;
        }
        
		sourceID = [l_soundObject m_id];
		alSourceStop(sourceID);
	}
    
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error play sound: %x\n", error);
		exit(1);
	}
}


-(void) rewindSoundWithKey:(NSString *) soundKey 
{
	SoundObject * l_soundObject = [soundDictionary objectForKey:soundKey];
	if (l_soundObject == nil) return;
    if(!l_soundObject.m_isLoaded)
    {
        printf("You must load the sound before you rewindSoundWithKey.\n");
        return;
    }
	NSUInteger sourceID = [l_soundObject m_id];
	alSourceRewind (sourceID);
    
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error play sound: %x\n", error);
		exit(1);
	}
}

-(bool) isPlayingSoundWithKey:(NSString *) soundKey 
{
	SoundObject * l_soundObject = [soundDictionary objectForKey:soundKey];
	if (l_soundObject == nil) return NO;
    if(!l_soundObject.m_isLoaded)
    {
        return NO;
    }
	NSUInteger sourceID = [l_soundObject m_id];
	
	ALenum state;
	
    alGetSourcei(sourceID, AL_SOURCE_STATE, &state);
	
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error play sound: %x\n", error);
		exit(1);
	}
    
    return (state == AL_PLAYING);
}

-(void)FadeWithKey:(NSString *)a_soundKey duration:(float)a_duration volume:(float)a_volume stopEnd:(BOOL)a_stopEnd
{
	SoundObject * l_soundObject = [soundDictionary objectForKey:a_soundKey];
	if (l_soundObject == nil) return;
    if(!l_soundObject.m_isLoaded)
    {
        return;
    }
	NSUInteger sourceID = [l_soundObject m_id];
	FadingObject * l_fadingObject;
	for (int i = [m_fadeArray count] - 1; i >= 0; i--)
	{
		l_fadingObject = [m_fadeArray objectAtIndex:i];
		if(l_fadingObject.m_id == sourceID)
		{
			l_fadingObject.m_duration = a_duration;
			l_fadingObject.m_currentTime = 0.f;
			ALfloat l_temp;
			alGetSourcef(sourceID, AL_GAIN, &l_temp);
			l_fadingObject.m_volumeInit = l_temp;
			l_fadingObject.m_volumeEnd = a_volume;
			l_fadingObject.m_stopEnd = a_stopEnd;
			return;
		}
	}
	
	l_fadingObject = [[FadingObject alloc] init];
	l_fadingObject.m_id = sourceID;
	l_fadingObject.m_duration = a_duration;
	l_fadingObject.m_currentTime = 0.f;
	ALfloat l_temp;
	alGetSourcef(sourceID, AL_GAIN, &l_temp);
	l_fadingObject.m_volumeInit = l_temp;
	l_fadingObject.m_volumeEnd = a_volume;
	l_fadingObject.m_stopEnd = a_stopEnd;
	
	[m_fadeArray addObject:l_fadingObject];

    printf("Fade id = %d\n",l_fadingObject.m_id);
    
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error fade sound: %x\n", error);
		exit(1);
	}
}

-(void)UpdateFading:(NSTimeInterval)a_timeInterval
{
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error update fading sound: %x\n", error);
		exit(1);
	}
	int l_arraySize = [m_fadeArray count];
	float l_newVolume;
	FadingObject * l_fadingObject;
	for(int i = l_arraySize - 1; i >= 0; i--)
	{
		l_fadingObject = [m_fadeArray objectAtIndex:i];
		l_fadingObject.m_currentTime += a_timeInterval;
		if(l_fadingObject.m_currentTime > l_fadingObject.m_duration)
		{
			if(l_fadingObject.m_stopEnd)
			{
                ALenum state;
                
                alGetSourcei(l_fadingObject.m_id, AL_SOURCE_STATE, &state);
                
                ALenum  error = AL_NO_ERROR;
                if((error = alGetError()) != AL_NO_ERROR) 
                {
                    printf("error play sound: %x\n", error);
                    exit(1);
                }
                
                if(state != AL_STOPPED)
				{
                    alSourceStop(l_fadingObject.m_id);
                    printf("alSourceStop id = %d\n",l_fadingObject.m_id);
                    if((error = alGetError()) != AL_NO_ERROR) 
                    {
                        printf("error play sound: %x\n", error);
                        exit(1);
                    }
                }
			}
			else
			{
				alSourcef(l_fadingObject.m_id, AL_GAIN, l_fadingObject.m_volumeEnd);
                printf("set gain id = %d\n",l_fadingObject.m_id);
			}

			[l_fadingObject release];
			[m_fadeArray removeObjectAtIndex:i];
            continue;
		}
		
        l_newVolume = l_fadingObject.m_volumeInit + (l_fadingObject.m_currentTime / l_fadingObject.m_duration) * (l_fadingObject.m_volumeEnd - l_fadingObject.m_volumeInit);
        l_newVolume = max(l_newVolume, 0.f);
        
        ALenum state;
        
        alGetSourcei(l_fadingObject.m_id, AL_SOURCE_STATE, &state);
        
        ALenum  error = AL_NO_ERROR;
        if((error = alGetError()) != AL_NO_ERROR) 
        {
            printf("error play sound: %x\n", error);
            exit(1);
        }
        
        if(state != AL_STOPPED)
        {
            alSourcef(l_fadingObject.m_id, AL_GAIN, l_newVolume);
        }
        
        if((error = alGetError()) != AL_NO_ERROR) 
        {
            printf("error play sound: %x\n", error);
            exit(1);
        }
	}
    
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error update fading sound: %x\n", error);
		exit(1);
	}
}

-(void)ReleaseFading
{
	int l_arraySize = [m_fadeArray count];
	FadingObject * l_fadingObject;
	for(int i = l_arraySize - 1; i >= 0; i--)
	{
		l_fadingObject = [m_fadeArray objectAtIndex:i];

		alSourceStop(l_fadingObject.m_id);
	
		[l_fadingObject release];
		[m_fadeArray removeObjectAtIndex:i];
	}	
    
    ALenum  error = AL_NO_ERROR;
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error release fading sound: %x\n", error);
		exit(1);
	}
}

-(void)RemoveFadingId:(unsigned int)a_id
{
    int l_arraySize = [m_fadeArray count];
	FadingObject * l_fadingObject;
	for(int i = l_arraySize - 1; i >= 0; i--)
	{
		l_fadingObject = [m_fadeArray objectAtIndex:i];
        if(l_fadingObject.m_id == a_id)
        {
            alSourceStop(l_fadingObject.m_id);
            [l_fadingObject release];
            [m_fadeArray removeObjectAtIndex:i];
            return;
        }
	}	
}

// add the metadata of a sound. Only called once per sound in the run. So we don't need to set these datas again.
-(BOOL)AddMetadata:(NSString *)a_soundKey 
           fileExt:(NSString *)a_fileExt
              loop:(bool)loops 
          pitchVar:(float)a_pitchVar
         permanent:(BOOL)a_permanent
{
	[soundDictionary setObject:[[SoundObject alloc] initWithExt:a_fileExt pitchVar:a_pitchVar loop:loops permanent:a_permanent] forKey:a_soundKey];
    
    if(a_permanent)
    {
        [self loadSoundWithKey:a_soundKey];
    }
    return YES;
}

// add the metadata of a sound. Only called once per sound in the run. So we don't need to set these datas again.
-(BOOL)AddMetadata:(NSString *)_soundKey 
           fileExt:(NSString *)a_fileExt
              loop:(bool)loops 
          pitchVar:(float)a_pitchVar
{
	return [self AddMetadata:_soundKey 
                     fileExt:a_fileExt
                        loop:loops 
                    pitchVar:a_pitchVar
                    permanent:NO];
}

-(BOOL)AddMetadata:(NSString *)_soundKey 
           fileExt:(NSString *)a_fileExt
              loop:(bool)loops 
{
   return [self AddMetadata:_soundKey 
              fileExt:a_fileExt
                 loop:loops 
             pitchVar:0.f
           ];
}

-(bool) loadSoundWithKey:(NSString *)a_soundKey
{
	if(!SOUND_ENABLE)
	{
		return YES;
	}

    
    SoundObject * l_soundObject = [soundDictionary objectForKey:a_soundKey];
    NSString * l_fileExt;
    BOOL    l_loops;
    if (l_soundObject == nil) 
    {
        return NO;
    }
    else
    {
        l_fileExt = [l_soundObject m_fileExt];
        l_loops = [l_soundObject m_loop];
    }
    
	ALvoid * outData;
	ALenum  error = AL_NO_ERROR;
	ALenum  format;
	ALsizei size;
	ALsizei freq;
	
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error loading sound: %x\n", error);
		exit(1);
	}
    
	NSBundle * bundle = [NSBundle mainBundle];
	
	// get some audio data from a wave file
	CFURLRef fileURL = (CFURLRef)[[NSURL fileURLWithPath:[bundle pathForResource:a_soundKey ofType:l_fileExt]] retain];
	
	if (!fileURL)
	{
		printf("file not found.");
		return false;
	}
	
	outData = MyGetOpenALAudioData(fileURL, &size, &format, &freq);
	
	CFRelease(fileURL);
	
	if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error loading sound: %x\n", error);
		exit(1);
	}
	
	printf("getting a free buffer from openAL.");
	NSUInteger bufferID;
	// grab a buffer ID from openAL
	alGenBuffers(1, &bufferID);
	
	printf("loading audio data into openAL buffer.");
	// load the awaiting data blob into the openAL buffer.
	alBufferData(bufferID,format,outData,size,freq); 
	
	printf("getting a free source from openAL.");
	NSUInteger sourceID;
	// grab a source ID from openAL
	alGenSources(1, &sourceID); 
	
	printf("attatching the buffer to the source and setting up preferences");
	// attach the buffer to the source
	alSourcei(sourceID, AL_BUFFER, bufferID);
	// set some basic source prefs
	alSourcef(sourceID, AL_PITCH, 1.0f);
	alSourcef(sourceID, AL_GAIN, 1.0f);
	if (l_loops) alSourcei(sourceID, AL_LOOPING, AL_TRUE);
    
    if((error = alGetError()) != AL_NO_ERROR) 
    {
		printf("error playing sound during loading: %x\n", error);
		exit(1);
	}
	
    l_soundObject.m_id = sourceID;
    l_soundObject.m_bufferID = bufferID;
    l_soundObject.m_isLoaded = YES;
    
	printf("free %i bytes of temporary allocated memory.\n", size);
	// clean up the buffer
	if (outData)
	{
		free(outData);
		outData = NULL;
	}
	
	return true;	
}

-(BOOL)DeleteKey:(NSString * )a_soundKey
{
    SoundObject * l_soundObject = [soundDictionary objectForKey:a_soundKey];
    if (l_soundObject == nil) 
    {
        return NO;
    }
    
    [self RemoveFadingId:l_soundObject.m_id];
    [l_soundObject Unload];
    return YES;
}

-(BOOL)SetNewList:(NSArray *)a_list
{
    if(a_list == nil)
    {
        return YES;
    }
    
    SoundObject * l_soundObject;
    NSString * l_dictionaryKey;
    NSArray * l_dictionaryKeyList = [soundDictionary allKeys];
    BOOL    l_isInList;

    for(unsigned int i = 0; i < [l_dictionaryKeyList count]; i++)
    {
        l_dictionaryKey = [l_dictionaryKeyList objectAtIndex:i];
        l_soundObject = [soundDictionary objectForKey:l_dictionaryKey];
        l_isInList = NO;
        
        if(l_soundObject == nil)
        {
            printf("In SetNewList : sound object not found.\n");
            return NO;
        }
        if(![l_soundObject m_isLoaded] || [l_soundObject m_isPermanent])
        {
            continue;
        }
        
        for(int j = 0; j < [a_list count] ;j++)
        {
            if( l_dictionaryKey == [a_list objectAtIndex:j] )
            {
                l_isInList = YES;
            }
        }
        
        if(!l_isInList)
        {
            [self DeleteKey:l_dictionaryKey];
        }
    }
    
    NSString * l_newSoundName;
    for(int k = 0; k < [a_list count] ;k++)
    {
        l_newSoundName = [a_list objectAtIndex:k];
        l_soundObject = [soundDictionary objectForKey:l_newSoundName];
        
        if (l_soundObject == nil) 
        {
            printf("Errot want to load a sound not in the dictionary\n");
            return NO;
        }
        if(!l_soundObject.m_isLoaded)
        {
            [self loadSoundWithKey:[a_list objectAtIndex:k]];
        }
    }
    
    //[a_list release];
    //[l_dictionaryKey release];
    //[l_dictionaryKeyList release];
    return YES;
}

@end

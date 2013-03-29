//
//  InMemoryAudioFile.h
//  HelloWorld
//
//  Created by Aran Mulholland on 22/02/09.
//  Copyright 2009 Aran Mulholland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>
#include <sys/time.h>

typedef struct datas{
	UInt16	*data;	
	SInt64	packetIndex;	
	SInt64	packetCount;
	float	volume;
} Audiodata;

@interface InMemoryAudioFile : NSObject {
	NSString						*m_SoundIdString;	// id of this object
	AudioStreamBasicDescription		mDataFormat;                    
    AudioFileID						mAudioFile;                     
    UInt32							bufferByteSize;                 
    SInt64							mCurrentPacket;                 
    UInt32							mNumPacketsToRead;              
    AudioStreamPacketDescription	*mPacketDescs;
	Audiodata						*m_actualData;		// actual buffer plaing
	Audiodata						*m_nextData;
	NSMutableArray					*m_SoundPathArray;	// Array which contain all the sound paths of this object, they will be cross mix randomly
	SInt64							m_overlap;			// overlap between the two sounds (in sample)
	
	float							m_Volume;
	BOOL							m_loop;
	BOOL							m_FinishedPlaying;
	
	// RMS
	float							*m_RMSBuffer;		// buffer containing the m_RMSSize last samples readed
	int								m_RMSBufferIndex;	// index of the last sample recorded into the rmsbuffer
	SInt64							m_RMSSize;			// size of this buffer
	
	// Fading
	float							m_prevVolume;		// previous volume
	float							m_VolumeTarget;		// target volume for fading
	NSTimeInterval					m_FadingTime;		// fading time
	NSTimeInterval					m_TimeSinceFading;	// tick when fadong begin
}
//opens a wav file
-(OSStatus)open:(NSString *)filePath;

// add a file, which will be played randomly with fading
-(void)addFile:(NSString *)filePath;

//gets the infor about a wav file, stores it locally
-(OSStatus)getFileInfo:(Audiodata *)thedata;

//gets the next packet from the buffer, returns -1 if we have reached the end of the buffer
-(UInt16)getNextPacket;

//gets the current index (where we are up to in the buffer)
-(SInt64)getIndex;

//reset the index to the start of the file
-(void)reset;

-(OSStatus)LoadNextDataStepOne;

-(void)LoadNextDataStepTwo;

-(void)FadeVolumeTo:(float)newVolume Time:(NSTimeInterval)time;

-(void)UpdateFadingVolume;

-(void)SetRMSBufferSize:(int)size;

-(float)GetRMSLevel;

-(void)SetVolume:(float)newVolume;

@end

//
//  InMemoryAudioFile.m
//  HelloWorld
//
//  Created by Aran Mulholland on 22/02/09.
//  Copyright 2009 Aran Mulholland. All rights reserved.
//

#import "InMemoryAudioFile.h"
//#include <pthread.h>

#define MAXOVERLAP 160100

@implementation InMemoryAudioFile

//overide init method
- (id)init 
{ 
    self = [super init];
	m_SoundPathArray = [[NSMutableArray alloc] init];
	m_actualData = (Audiodata *)malloc(sizeof(Audiodata));
	m_nextData = (Audiodata *)malloc(sizeof(Audiodata));
	//set the index
	m_actualData->packetIndex = 0;
	m_nextData->packetIndex = 0;
	m_actualData->data = nil;
	m_nextData->data = nil;
	m_overlap = 160100;
	m_loop = NO;
	m_FinishedPlaying = NO;
	return self;
}

- (void)dealloc {
	//release the AudioBuffer
	free(m_actualData);
	free(m_nextData);
    [super dealloc];
}

//open and read a wav file
-(OSStatus)open:(NSString *)filePath{
	
	//print out the file path
	NSLog(@"FilePath: ");
	NSLog(filePath);
	
	[m_SoundPathArray addObject:filePath];
	
	//get a ref to the audio file, need one to open it
	CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *)[filePath cStringUsingEncoding:[NSString defaultCStringEncoding]] , strlen([filePath cStringUsingEncoding:[NSString defaultCStringEncoding]]), false);
	
	//open the audio file
	OSStatus result = AudioFileOpenURL (audioFileURL, 0x01, 0, &mAudioFile);
	//were there any errors reading? if so deal with them first
	if (result != noErr) {
		NSLog([NSString stringWithFormat:@"Could not open file: %@", filePath]);
		m_actualData->packetCount = -1;
	}
	//otherwise
	else{
		//get the file info
		[self getFileInfo:m_actualData];
		//how many packets read? (packets are the number of stereo samples in this case)
		NSLog([NSString stringWithFormat:@"File Opened, packet Count: %d", m_actualData->packetCount]);
		
		UInt32 packetsRead = m_actualData->packetCount;
		OSStatus result = -1;
		
		//free the audioBuffer just in case it contains some data
		free(m_actualData->data);
		UInt32 numBytesRead = -1;
		//if we didn't get any packets dop nothing, nothing to read
		if (m_actualData->packetCount <= 0) { }
		//otherwise fill our in memory audio buffer with the whole file (i wouldnt use this with very large files btw)
		else{
			//allocate the buffer
			m_actualData->data = (UInt16 *)malloc(sizeof(UInt16) * 2 * m_actualData->packetCount);
			//read the packets
			result = AudioFileReadPackets (mAudioFile, false, &numBytesRead, NULL, 0, &packetsRead,  m_actualData->data); 
		}
		if (result==noErr){
			//print out general info about  the file
			NSLog([NSString stringWithFormat:@"Packets read from file: %d\n", packetsRead]);
			NSLog([NSString stringWithFormat:@"Bytes read from file: %d\n", numBytesRead]);
			//for a stereo 32 bit per sample file this is ok
			NSLog([NSString stringWithFormat:@"Sample count: %d\n", numBytesRead / 2]);
			//for a 32bit per stereo sample at 44100khz this is correct
			NSLog([NSString stringWithFormat:@"Time in Seconds: %f.4\n", ((float)numBytesRead / 4.0) / 44100.0]);
		}
	}

	CFRelease (audioFileURL);     

	return result;
}

//open and read a wav file
-(void)addFile:(NSString *)filePath
{	
	[m_SoundPathArray addObject:filePath];
	if(m_nextData->data == nil)
		[self LoadNextDataStepOne];
		
}


- (OSStatus) getFileInfo:(Audiodata *)thedata {
	
	OSStatus	result = -1;
	
	if (mAudioFile == nil){}
	else{
		UInt32 dataSize = sizeof thedata->packetCount;
		result = AudioFileGetProperty(mAudioFile, kAudioFilePropertyAudioDataPacketCount, &dataSize, &thedata->packetCount);
		if (result!=noErr) {
			thedata->packetCount = -1;
		}
	}
	return result;
}


//gets the next packet from the buffer, if we have reached the end of the buffer return 0
-(UInt16)getNextPacket{
	if(m_actualData == nil)
		NSLog(@"error InMemoryAudioFile bad initialisation");
	
	UInt16 returnValue = 0;
	
	if(m_RMSBufferIndex >= m_RMSSize)
	{
		m_RMSBufferIndex = 0;
	}
	
	//if the packetCount has gone to the end of the file, reset it. Audio will loop.
	if (m_actualData->packetIndex >= 2*m_actualData->packetCount)
	{
		if(!m_loop)
		{
			m_FinishedPlaying = YES;
			[self reset];
		}
		Audiodata *temp = m_actualData;
		m_actualData = m_nextData;
		m_nextData = temp;
		m_nextData->packetIndex = 0;
		
		[NSThread detachNewThreadSelector:@selector(LoadNextDataStepOne) toTarget:self withObject:nil];
//		[self LoadNextDataStepOne];
		NSLog(@"load next file");
	}
	
	//i always like to set a variable and then return it during development so i can
	//see the value while debugging
	if((m_actualData->packetIndex > (2*m_actualData->packetCount - m_overlap)) && (m_nextData->data != nil))
	{	
		signed short a = (signed short)m_actualData->data[m_actualData->packetIndex++];
		signed short b = (signed short)m_nextData->data[m_nextData->packetIndex++];
		float attenuation = (float)(2*m_actualData->packetCount - m_actualData->packetIndex)/(float)m_overlap;
		returnValue = m_Volume*(attenuation*(float)a + (1. - attenuation)*(float)b);
		float oh = (signed short)returnValue*(signed short)returnValue;
		m_RMSBuffer[m_RMSBufferIndex++] = oh;
		return returnValue;
	}
	
	if(m_nextData->data == nil && m_actualData->packetIndex > (2*m_actualData->packetCount))
	{
		m_actualData->packetIndex = 0;
	}
	returnValue = m_Volume*(signed short)m_actualData->data[m_actualData->packetIndex++];
	float oh = (signed short)returnValue*(signed short)returnValue;
	m_RMSBuffer[m_RMSBufferIndex++] = oh;
	return returnValue;
}

// gets the current index (where we are up to in the buffer)
-(SInt64)getIndex{
	return m_actualData->packetIndex;
}

-(void)reset{
	m_actualData->packetIndex = 0;
	m_nextData->packetIndex = 0;
}

-(OSStatus)LoadNextDataStepOne
{
	m_nextData->packetIndex = 0;
	
	int i = (floor)(((float)rand()/(float)RAND_MAX + 0.5) * [m_SoundPathArray count]) - 1;
	printf("%d \n", i);
	if(i>=[m_SoundPathArray count])
		i = [m_SoundPathArray count] - 1;
	NSString *filePath = [m_SoundPathArray objectAtIndex:i];
	
	//get a ref to the audio file, need one to open it
	CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *)[filePath cStringUsingEncoding:[NSString defaultCStringEncoding]] , strlen([filePath cStringUsingEncoding:[NSString defaultCStringEncoding]]), false);
	//open the audio file
	OSStatus result = AudioFileOpenURL (audioFileURL, 0x01, 0, &mAudioFile);

	//were there any errors reading? if so deal with them first
	if (result != noErr) {
		NSLog([NSString stringWithFormat:@"Could not open file: %s", filePath]);
		m_nextData->packetCount = -1;
	}
	//otherwise
	else
	{
		[self LoadNextDataStepTwo];	
	}
	CFRelease (audioFileURL);     
	
	return result;
}

-(void)LoadNextDataStepTwo
{
	//get the file info
	[self getFileInfo:m_nextData];
	m_overlap = (m_nextData->packetCount > 2*MAXOVERLAP) ? MAXOVERLAP : m_nextData->packetCount/4;

	//how many packets read? (packets are the number of stereo samples in this case)
	NSLog([NSString stringWithFormat:@"File Opened, packet Count: %d", m_nextData->packetCount]);
	
	UInt32 packetsRead = m_nextData->packetCount;
	OSStatus result = -1;
	
	//free the audioBuffer just in case it contains some data
	free(m_nextData->data);
	UInt32 numBytesRead = -1;
	//if we didn't get any packets dop nothing, nothing to read
	if (m_nextData->packetCount <= 0) { }
	//otherwise fill our in memory audio buffer with the whole file (i wouldnt use this with very large files btw)
	else{
		//allocate the buffer
		m_nextData->data = (UInt16 *)malloc(sizeof(UInt16) * 2*m_nextData->packetCount);
					
		//read the packets
		result = AudioFileReadPackets (mAudioFile, false, &numBytesRead, NULL, 0, &packetsRead,  m_nextData->data); 
	}
//	return result;
}

-(void)FadeVolumeTo:(float)newVolume Time:(NSTimeInterval)time
{
	m_TimeSinceFading = [NSDate timeIntervalSinceReferenceDate];
	m_VolumeTarget = newVolume;
	m_FadingTime = time;
	m_prevVolume = m_Volume;
	[self performSelector:@selector(UpdateFadingVolume) withObject:nil afterDelay:0.1];
}

-(void)UpdateFadingVolume
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	if((now - m_TimeSinceFading) >= m_FadingTime)
	{
		m_Volume = m_VolumeTarget;
		return;
	}
	m_Volume = ((float)(now - m_TimeSinceFading)/(float)m_FadingTime)*(m_VolumeTarget - m_prevVolume) + m_prevVolume;
	[self performSelector:@selector(UpdateFadingVolume) withObject:nil afterDelay:0.1];
}

-(void)SetRMSBufferSize:(int)size
{
	m_RMSSize = size;
	m_RMSBuffer = (float *)malloc(m_RMSSize * sizeof(float));
}

-(float)GetRMSLevel
{
	float returnValue = 0;
	for(int i = 0; i < m_RMSSize; i++)
	{
		returnValue += m_RMSBuffer[i];	
	}
	returnValue = sqrt(returnValue / m_RMSSize);
	return returnValue;
}


-(void)SetVolume:(float)newVolume
{
	m_Volume = newVolume;
}

@end

//
//  State.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "State.h"
#import "EAGLView.h"

@implementation State

-(void)StateInit
{
}

-(id)InitFromMenu
{
	return [self init];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{

}

-(id)GetNoteBook
{
	return nil;
}

-(NSArray *)GetSoundArray
{
    return nil;
}

-(void)SimpleClick:(CGPoint)a_touchLocation
{
	return;
}

-(void)Touch:(CGPoint)a_touchLocation
{
	return;
}

// Multi touch event.
-(void)MultiTouch:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	
}

// Multi touch event.
-(void)MultiTouchMove:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	return;
}

-(void)TouchEnded:(CGPoint)a_touchLocation
{
	return;
}

-(void)SkipSpeaking
{
	return;
}	

// Device is shaked.
-(void)Shake
{
	return;
}

-(void)Event1:(int)a_value
{
	return;
}

-(void)Event2:(int)a_value
{
	return;
}

-(void)Event3:(int)a_value
{
	return;
}

-(void)Eventf1:(float)a_value
{
	return;
}

-(void)Terminate
{
	[[EAGLView sharedEAGLView] Reset];
	
	for(int i = 0; i < m_levelData.m_arraySize; i++)
	{
		[m_levelData.m_textureArray[i] release];
	}
	free(m_levelData.m_textureArray);
	
	[super release];
}

@end

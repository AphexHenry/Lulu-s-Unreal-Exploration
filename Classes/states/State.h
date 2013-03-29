//
//  State.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// State enumeration, in order of apparition.
typedef enum StateIndex
{ 
	STATE_INTRO = -1,
	STATE_MENU,
	STATE_LUCIOLES,
	STATE_LARVE,
	STATE_SPIRAL,
	STATE_PARTICLE_FIGHT,
	STATE_PARTICLE_NEXT_GENERATION_PUPPET,
    STATE_SEA,
    STATE_DREAM_IMMORTAL,
	STATE_COUNT
}StateIndex;

// Basic texture of all the states.
// Must be filled in openGL.
// 	see m_levelData.m_textureArray
typedef enum TextureGlobal
{ 
	TEXTURE_BACKGROUND,
	TEXTURE_MOON,
	TEXTURE_SHADOW,
	TEXTURE_COUNT
}TextureGlobal;

// struct containing the datas of a level.
//BOOL m_isMiddleElement : if true, there is a middle plan element in the environment.
//BOOL m_isAroundElement : if true, there is a first plan element in the environment.
//float	m_sizeFactorEnd : factor of the decrease of the size of the elements when far.
//int		m_duplicate : should we duplicate the background.
//float	m_widthOnHeigth : proportion of the environment.
//float	m_size : size of the environment.
//int		m_snakePartQuantity : number of part in the snake body.
//float	m_snakeLengthBetweenParts : distance between two parts of the snake.
//	float	m_snakeLengthBetweenHeadAndBody distance between the head and the first body part.
// float m_snakeSizeHead : size of the head of the snake.
// float m_snakeSizeBody : size of the first element of the body of the snake.
typedef struct LevelData
{
	int		m_duplicate;
	float	m_widthOnHeigth;
	float	m_size;
	int		m_snakePartQuantity;
	float	m_snakeLengthBetweenParts;
	float	m_snakeLengthBetweenHeadAndBody;
	float	m_snakeSizeHead;
	float	m_snakeSizeBody;
	
	NSString** m_textureArray;
	int		m_arraySize;
}LevelData;

@interface State : NSObject 
{
    // datas of the state.
	LevelData m_levelData;
    // index of the state.
	int m_index;
}

// Init the state.
-(void)StateInit;
// init from the main menu state.
-(id)InitFromMenu;
// Update.
-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval;
// return the id of the notebook state.
-(id)GetNoteBook;
// return the list of the sound that must be activated.
-(NSArray *)GetSoundArray;
//Terminate.
-(void)Terminate;
// Simple click event.
-(void)SimpleClick:(CGPoint)a_touchLocation;
// Touch event.
-(void)Touch:(CGPoint)a_touchLocation;
// Multi touch event.
-(void)MultiTouch:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2;
// Multi touch move event.
-(void)MultiTouchMove:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2;
// Touch moved.
-(void)TouchMoved:(CGPoint)a_touchLocation;
// Touche end event.
-(void)TouchEnded:(CGPoint)a_touchLocation;
// skip Lulu's speaking event.
-(void)SkipSpeaking;
// Device is shaked.
-(void)Shake;
// these methods are used for the object to communicate with the states.
-(void)Event1:(int)a_value;
-(void)Event2:(int)a_value;
-(void)Event3:(int)a_value;
-(void)Eventf1:(float)a_value;

@end

//
//  StateTheatreRateIt.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


#import "ParticleLetterEvolved.h"
#import "Puppet.h"
#import "State.h"

@interface LettersDatas : NSObject
{
    BOOL m_touched;
    CGPoint m_positionAttractor;
    ParticleLetterEvolved * m_letter;
    int m_indexFinger;
    CGPoint m_decay;
}

-(void)SetIndex:(int)a_index decay:(CGPoint)a_decay;

@property (nonatomic, retain) ParticleLetterEvolved * m_letter;
@property (readwrite) int m_indexFinger;
@property BOOL m_touched;
@property CGPoint m_decay;

@end;

// plan enumeration
typedef enum TextureStateTheatreTreesFast
{
	TEXTURE_T_TREESFAST_LULU_SLEEP = TEXTURE_COUNT,
    TEXTURE_T_TREESFAST_BACKPSYCH1,
    TEXTURE_T_TREESFAST_BACKPSYCH2,
    TEXTURE_T_TREESFAST_STICK,
    TEXTURE_T_TREESFAST_LULU_SLEEPING_BAG,
    TEXTURE_T_TREESFAST_LETTER_Z,
    TEXTURE_T_TREESFAST_WINGS_0,
    TEXTURE_T_TREESFAST_WINGS_1,
	TEXTURE_T_TREESFAST_COUNT
}TextureStateTheatreTreesFast;

@interface StateTheatreTreesFast : State
{
    // position of the finger on the screen.
	CGPoint				m_fingerPosition[2];
    BOOL                m_multiTouchMondayToTuesday;
    
	CGPoint				m_skyDecay, m_screenPos;
	NSTimeInterval		m_time;
    
    CGPoint mPositionInScene;
    CGPoint mTreesPosition;
    CGPoint mSpeedInScene;
    BOOL mGoLetters;
    
    NSMutableArray *       m_letters;
}

-(void)Draw;
-(CGPoint)GetDecayForLetters:(CGPoint)a_position;
-(void)UpdateLetters:(NSTimeInterval)a_timeInterval;

@end

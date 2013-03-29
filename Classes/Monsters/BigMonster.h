//
//  BigMonster.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// plan enumeration
typedef struct MonsterPart
{
	float m_size;
	float	m_widthOnHeight;
	CGPoint m_positionBase;
	CGPoint m_positionDraw;
	float	m_angle;
	NSTimeInterval m_angleTimer;
	float m_angleBase;
    int   m_texture;
	struct MonsterPart * m_child;
	
} MonsterPart;

@interface BigMonster : NSObject 
{
    NSTimeInterval m_timer;
	NSTimeInterval m_growTimer;
	CGPoint m_positionGoal;
	CGPoint	m_decayGrow;
	// Position decay to remove too much speed.
	CGPoint	m_decayPositionToLimitSpeed;
	CGPoint	m_decaySpeedToLimitSpeed;
	BOOL	m_blockRoot;
    BOOL    m_transparency;
	
	// Grow speed.
	float	m_speedGrow;
	
	float	m_groundY;
	int		m_texture;
    int     m_numTexture;
    float   m_alpha;
	
	float	m_widthOnHeight;
	
	float	m_size;
	float	m_sizeLimit;
	float	m_sizeCoeff;
    
    float   m_speedGrowCoeff;
	
	// break until the timer > 0.;
	NSTimeInterval m_hurtBreakTimer;
	
	MonsterPart * m_head;
	MonsterPart * m_tail;
}

@property CGPoint m_position;

// init.
-(id)initWithPosition:(CGPoint)a_position groundY:(float)a_groundY	texture:(int)a_texture;

-(id)initWithPosition:(CGPoint)a_position 
			  groundY:(float)a_groundY	
			  texture:(int)a_texture 
				block:(BOOL)a_blockRoot
         transparency:(BOOL)a_transparency
            sizeLimit:(float)a_size
           numTexture:(int)a_numTexture
            growSpeed:(float)a_growSpeed;

// update.
-(void)Update:(NSTimeInterval)a_timeInterval position:(CGPoint)a_nextPosition;

-(void)CreateNewHead;

-(void)SetDecayDraw:(CGPoint)a_decay;

// Set the global alpha of the monster.
-(void)SetAlpha:(float)a_alpha;

// return the position of the fatal part of the monster.
-(CGPoint)GetKillPosition;
// hurt the monster.
-(void)Hurt;

-(void)draw;

@end

//
//  StateLucioles.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhysicPendulum.h"

// plan enumeration
typedef enum SequenceState
{ 
    RESET_SEQUENCE,
	SEQUENCE_STATE_WAIT_FOR_BEGIN,
	SEQUENCE_STATE_CHANGE_PANEL,
	SEQUENCE_STATE_WAIT_FOR_END,
	SEQUENCE_STATE_END,
}SequenceState;

// m_isGhost if true, the blend function is the ghost one.
@interface PanelEvent : NSObject
{
	NSTimeInterval	m_triggerTimer;
	NSTimeInterval	m_endTimer;
	int				m_texture;
} 

@property NSTimeInterval	m_triggerTimer;
@property NSTimeInterval	m_endTimer;
@property int				m_texture;

-(id)InitTexture:(int)a_texture begin:(NSTimeInterval)a_triggerTimer end:(NSTimeInterval)a_endTimer;

@end

@interface Puppet : NSObject
{	
	// pointor to the head of the pendulum.
	PhysicPendulum * m_pendulumStick;
	PhysicPendulum * m_pendulumStickPanel;
	
	int m_puppetTexture;
	int m_markerTexture;
	int m_nextTexture;
	BOOL m_changeTexture;
	int m_stickTexture;
	int m_panelTexture;
	int m_panelTexturePrevious;
	
	BOOL m_moved;
	BOOL m_blockRotation;
	BOOL m_flyingMarker;
	BOOL m_isStatic;
    
	// position of the finger on the screen.
	float				m_stickLength;
	float				m_stickAngleConstant;
	CGPoint				m_stickEndPosition;
	CGPoint				m_lastPosition;
	
	float				m_panelSpeedY;
	float				m_panelPositionY;
	
	BOOL				m_luluLeft;
	float				m_luluTurnLast;
	float				m_luluTurnSpeed;
	float				m_luluTurnLastDeformation;
	float				m_luluForcedDeformation;

	float				m_puppetSize;
	
	NSArray *			m_sequenceArray;
	int					m_sequenceIndex;
	NSTimeInterval		m_sequenceTimer;
	NSTimeInterval		m_panelChangeTimer;
	float				m_panelWidthOnHeight;
	SequenceState		m_sequenceState;
}

// init pendulum.
-(id)InitWithTexturePuppet:(int)a_puppetTexture 
					 Stick:(int)a_stickTexture 
			  InitPosition:(CGPoint)a_positionInit 
			 PanelSequence:(NSArray *)a_sequenceArray;

-(id)InitWithTexturePuppet:(int)a_puppetTexture 
					 Stick:(int)a_stickTexture 
			  InitPosition:(CGPoint)a_positionInit 
			 PanelSequence:(NSArray *)a_sequenceArray
				StickAngle:(float)a_stickAngle
				PuppetSize:(float)a_puppetSize
					Marker:(int)a_markerTexture
			  FlyingMarker:(BOOL)a_flyingMarker
                  IsStatic:(BOOL)a_isStatic;

// updtate the positions of the snake parts and draw them.
-(void)UpdateWithPosition:(CGPoint)a_position timeInterval:(NSTimeInterval)a_timeInterval;

-(void)UpdateSequence:(NSTimeInterval)a_timeInterval;
-(void)UpdatePuppet:(NSTimeInterval)a_timeInterval;
-(void)UpdatePanel:(NSTimeInterval)a_timeInterval;
// Return the position of the puppet.
-(CGPoint)GetPosition;
// Get the current puppet deformation.
-(float)GetDeformation;
// Set a new panel sequence.
-(void)SetSequence:(NSArray *)a_newSequence;
// Change the texture.
-(void)SetTexture:(int)a_newTexture;
-(void)BlockRotation:(BOOL)a_blockRotation;

@end

//
//  StateTheatreNextGeneration.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "State.h"
#import "PhysicPendulum.h"
#import "PuppetEvolved.h"

// plan enumeration
typedef enum TextureStateTheatreNextGeneration
{ 
	TEXTURE_T_NEXT_GENERATION_FRONT = TEXTURE_COUNT,
	TEXTURE_T_NEXT_GENERATION_BACKGROUND_AROUND,
	TEXTURE_T_NEXT_GENERATION_STICK,
	TEXTURE_T_NEXT_GENERATION_PUPPET_BODY,
	TEXTURE_T_NEXT_GENERATION_PUPPET_HEAD,
	TEXTURE_T_NEXT_GENERATION_PUPPET_ARM,
	TEXTURE_T_NEXT_GENERATION_PUPPET_SWORD,
	TEXTURE_T_NEXT_GENERATION_GEAR,
	TEXTURE_T_NEXT_GENERATION_LIGHTBUG,
	TEXTURE_T_NEXT_GENERATION_DEAD_THING,
	TEXTURE_T_NEXT_GENERATION_MOUSSE,
	TEXTURE_T_NEXT_GENERATION_BEAST,
	TEXTURE_T_NEXT_GENERATION_FLOWER,
	TEXTURE_T_NEXT_GENERATION_GRASS,
	TEXTURE_T_NEXT_GENERATION_MONSTER_PART_1,
	TEXTURE_T_NEXT_GENERATION_MONSTER_PART_2,
	TEXTURE_T_NEXT_GENERATION_MONSTER_1_PART_1,
	TEXTURE_T_NEXT_GENERATION_MONSTER_1_PART_2,
	TEXTURE_T_NEXT_GENERATION_MONSTER_2_PART_1,
	TEXTURE_T_NEXT_GENERATION_MONSTER_2_PART_2,
	TEXTURE_T_NEXT_GENERATION_MONSTER_3_PART_1,
	TEXTURE_T_NEXT_GENERATION_MONSTER_3_PART_2,
	TEXTURE_T_NEXT_GENERATION_MONSTER_4_PART_1,
	TEXTURE_T_NEXT_GENERATION_MONSTER_4_PART_2,
	TEXTURE_T_NEXT_GENERATION_COUNT,
}TextureStateTheatreNextGeneration;

@interface StateTheatreNextGeneration : State
{
	CGPoint				m_fingerPosition[2];
	
	// Current position of the pendulum base.
	CGPoint m_headPosition;
	CGPoint m_headSpeed;
	
	float	m_headDeformation;
	float	m_aroundTextureDeformationFrequency;
	float	m_aroundTextureDeformation;
	
	BOOL		m_multiTouchMondayToTuesday;
	BOOL		m_isCrazy;
	PuppetEvolved * m_puppet;
	
	CGPoint				m_skyDecay;
	NSTimeInterval		m_time;
	
	float m_puppetSpeed;
}

-(BOOL)UpdateKilling:(NSTimeInterval)a_timeInterval;

-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval;

@end

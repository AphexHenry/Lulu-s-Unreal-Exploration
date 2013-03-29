//
//  PuppetEvolved.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhysicPendulum.h"
#import "Puppet.h"

@interface PuppetEvolved : Puppet
{	
	int m_armTexture;
	int m_swordTexture;
	int m_headTexture;
	int m_legTexture;
	CGPoint m_handControlerPosition;
	CGPoint m_bodyControlerPosition;
	CGPoint m_swordPosition;
	CGPoint m_headPosition;
	float m_armAngleDegree;
	float m_speedSword;
	
	float m_hitHeadRotation;
	float m_hitTimer;
	float m_crazyVolume;
	
	PhysicPendulum * m_pendulumArm;
	PhysicPendulum *m_pendulumLeg[2];
	
}

// arm initialisation.
-(id)InitWithTexturePuppet:(int)a_puppetTexture
				TextureArm:(int)a_textureArm
			  TextureSword:(int)a_textureSword
					 Stick:(int)a_stickTexture 
			   TextureHead:(int)a_textureHead
				TextureLeg:(int)a_textureLeg
			  InitPosition:(CGPoint)a_positionInit 
			 PanelSequence:(NSArray *)a_sequenceArray;

-(void)UpdateWithPosition:(CGPoint)a_positionBody positionHand:(CGPoint)a_positionHand timeInterval:(NSTimeInterval)a_timeInterval;

-(void)DrawArm:(NSTimeInterval)a_timeInterval;

-(void)Hit:(int)a_value;

-(CGPoint)GetPositionControlerBody;

-(CGPoint)GetPositionControlerHand;

-(CGPoint)GetPositionSword;

-(CGPoint)GetPositionBody;

-(float)GetSpeedSword;

@end

@interface PuppetEvolvedPig : PuppetEvolved
{
    NSTimeInterval m_time;
    int     m_texturePig;
    float   m_movement;
    float   m_movementSpeed;
}

-(id)InitWithTexturePuppet:(int)a_puppetTexture
                TextureArm:(int)a_textureArm
              TextureSword:(int)a_textureSword
                TexturePig:(int)a_texturePig
                     Stick:(int)a_stickTexture 
               TextureHead:(int)a_textureHead
                TextureLeg:(int)a_textureLeg
              InitPosition:(CGPoint)a_positionInit 
             PanelSequence:(NSArray *)a_sequenceArray;

-(void)SetSpeed:(float)a_speed;

-(float)GetVariation;

@end

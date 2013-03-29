//
//  Particle.h
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"
#import "Animation.h"
#import "PhysicPendulum.h"
#import "ParticleMonsterTheatre.h"

@interface ParticleMonsterTheatreTeleport : ParticleMonsterTheatre 
{
	BOOL			m_isHidden;
	BOOL			m_hasTeleported;
	
	CGPoint			m_position2;
	CGPoint			m_speed2;
	
	float			m_secondTextureAngle;
}

-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick;

// computation of the force applied on the particle
-(CGPoint)AttractorsInfluenceOn;

-(void)UpdateRotationWithTimeInterval:(NSTimeInterval)a_timeInterval;

@end

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

@interface ParticleMonsterTheatreFlower : ParticleMonsterTheatre 
{	
	float			m_wind;
	float			m_rotationAngleSpeed;
	float			m_rotationAngle;
}

-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick;

@end

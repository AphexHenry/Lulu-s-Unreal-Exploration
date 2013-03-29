//
//  Particle.h
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"

@interface ParticleSea : Particle 
{
	float m_angle;
	float m_deformation;
	float m_deformationSpeed;
	float m_widthOnHeight;
	float m_lastTranslate;
	float m_mass;
}

// update particles positions, put dead ones in the basket and get out new ones.
-(void)UpdateWithTimeInterval:(float)a_timeInterval;

// draw each partcicle as a circle
-(void)draw;

-(id)initWithTexture:(int)a_texture size:(float)a_size position:(float)a_position widthOnHeight:(float)a_widthOnHeight;

+(void)SetGroundY:(float)a_groundY;
+(void)SetDistance:(float)a_distance;
+(void)SetXTranslate:(float)a_xTranslate;
+(void)SetWavePosition:(float)a_xPosition;
+(void)SetWaveAmplitude:(float)a_amplitude;
+(void)SetPositionPuppet:(float)a_position;

@end

@interface ParticleSeaFlower : ParticleSea
{

}
@end
;

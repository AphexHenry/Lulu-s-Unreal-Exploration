//
//  Particle.h
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"
#import "Animation.h"

@interface ParticleBeast : Particle 
{
	float m_deformation;
	float m_deformationFrequency;
}

-(void)SetAnimation:(int)a_frame;

@end

//
//  Particle.h
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"

@interface ParticleBugSleep : Particle
{
    CGPoint mPositionAttractor;
    BOOL m_behind;
    float m_rotation;
    float m_rotationSpeed;
}

-(id)initWithTexture:(int)a_texture size:(float)a_size plan:(int)a_plan position:(CGPoint)aPosition;

+(void)SetGroundY:(float)a_groundY;

@end
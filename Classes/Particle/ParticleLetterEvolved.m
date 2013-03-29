//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleLetterEvolved.h"
#import "MathTools.h"

@implementation ParticleLetterEvolved

-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick groupIndex:(int)a_groupIndex initPosition:(CGPoint)a_position
{
    self = [super initWithTexture:a_texture textureStick:a_textureStick groupIndex:a_groupIndex initPosition:a_position];
    [m_particleLetterEvolvedContainer addObject:self];
	return self;
}

-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
//    m_strengthAttractor = (m_strengthAttractor - 1.f) * 0.97 + 1.f;
    [super UpdateWithTimeInterval:a_timeInterval];
}

-(BOOL)Touch:(CGPoint)a_position
{
    if(DistancePoint(a_position, m_position) < 3.f * m_size)
    {
        return YES;
    }
    
    return NO;
}

@end

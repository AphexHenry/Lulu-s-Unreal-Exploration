//
//  ParticleManager.h
//
//  Created by Baptiste Bohelay on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	This class is a singleton, it manage all the particles from the creation to the positions computation.
//	When the particles are dead, we put them into a basket and reinitialize them
//
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"
#import "MathTools.h"
#import "Particle.h"

// Definition of the evolution of a spacie.
// m_quantity : number of element of this spacie.
// m_generationMax : maximum generation attain by a particle of this spacie.
// m_numberOfGenerationMaxElement : number of element wich has attained this generation level.
typedef struct
{
	int				m_quantity;
	int				m_generationMax;
	int				m_numberOfGenerationMaxElement;
}SpacieStateCurrent;

@interface			ParticleManager : NSObject 
{	
	Particle	*m_activeparticlesBorders; // container filled with the adress of the first element of each group.
	Particle	*m_DeadParticlesBasket;		// container for the dead bubbles particles
	Particle	*m_CloudParticlesContainer; // container for the cloud particles
	
	NSTimeInterval	m_timeFrame;				// Time of a frame.
}

@property (nonatomic, assign)  Particle	*m_activeparticlesBorders;

// add new particle.
-(void)AddParticle:(Particle *)a_newParticle;													

// update particles positions, put dead ones in the basket and get out new ones.
-(void)UpdateParticlesWithTimeInterval:(float)a_timeInterval;			

// Get out the particles from the basket.
-(void)ActiveDeadParticles;

// Get out a given number of particles from the basket.
-(void)ActiveDeadParticles:(int)a_num;
//
//	take the dead particles in the basket and reinitialize them
//	if the number exceeds the limite (see constants), we stop the rescue
//
-(void)ActiveDeadParticlesFromGroup:(ParticleGroup)a_group;

// Kill all particles.
-(void)KillParticles;										

// draw each partcicle as a circle
-(void)drawself;											

// put the dead particles in the basket.
-(void)PutItInTheBasket:(Particle*)deadparticle;

// return the texture of the texture at the given position.
-(int)GetTextureWithPosition:(CGPoint)a_position;

-(Particle *)GetParticleWithPosition:(CGPoint)a_position distanceMin:(float)a_distanceMin;

// return the count of the given group.
-(int)GetCountFromGroup:(int)a_groupIndex;

// Get the inertia center of the particles.
-(CGPoint)GetParticlesCenterFromGroup:(int)a_groupIndex;

// the class is a singleton, we use this method to get the object
+(ParticleManager*)sharedParticleManager;						

@end

//
//  Mario.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BigMonster.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"
//#import "StateParticleFight.h"

#define MONSTER_PART_MAX 30
#define DISTANCE_FROM_CHILD 1.f
#define BIG_MONSTER_TEXTURE_WIDTH_ON_HEIGHT 1.f
#define BIG_MONSTER_SIZE_MAX 0.7f
#define BIG_MONSTER_SIZE_MIN 0.1f
#define BIG_MONSTER_MAX_ANGLE_DIFFERENCE (M_PI / 3.f)
#define BIG_MONSTER_SPEED_GROW_LIMIT 2.5f

@implementation BigMonster

@synthesize m_position;

// init.
-(id)initWithPosition:(CGPoint)a_position groundY:(float)a_groundY	texture:(int)a_texture
{
	m_position = a_position;
	m_speedGrow = 0.f;
	m_groundY = a_groundY;
	m_texture = a_texture;
	m_widthOnHeight = 1.f;
	m_sizeLimit = BIG_MONSTER_SIZE_MAX;
	m_size = BIG_MONSTER_SIZE_MAX;
	m_sizeCoeff = 1.f;
	m_decayPositionToLimitSpeed = CGPointMake(0.f, 0.f);
	m_decaySpeedToLimitSpeed = CGPointMake(0.f, 0.f);
	m_blockRoot = NO;
	
	CGPoint l_monsterPartPosition = a_position;
	MonsterPart * l_monsterPart = (MonsterPart *)malloc(sizeof(MonsterPart));
	l_monsterPart->m_positionBase =	l_monsterPartPosition;
	l_monsterPart->m_positionDraw = l_monsterPartPosition;
	//NSLog(@"First init : m_positionBase = (%f, %f), l_monsterPart->m_positionBase = (%f, %f), l_monsterPartPosition = (%f, %f)", l_monsterPart->m_positionDraw.x, l_monsterPart->m_positionDraw.y, l_monsterPart->m_positionBase.x, l_monsterPart->m_positionBase.y, l_monsterPartPosition.x, l_monsterPartPosition.y);
	l_monsterPart->m_size = 0.2f;
	l_monsterPart->m_angle = myRandom() * M_PI / 9.f;
	l_monsterPart->m_angleTimer = myRandom() * 3.f;
	l_monsterPart->m_angleBase = 0.f;
	l_monsterPart->m_widthOnHeight = 1.f;
    l_monsterPart->m_texture = -1;
	m_head = l_monsterPart;
	for(int i = 1; i < MONSTER_PART_MAX; i++)
	{
		l_monsterPart->m_child = (MonsterPart *)malloc(sizeof(MonsterPart));
		l_monsterPartPosition.x += 0.2;
		l_monsterPart->m_positionBase =	l_monsterPartPosition;
		l_monsterPart->m_positionDraw = l_monsterPartPosition;
		//NSLog(@"init the very if : m_positionDraw = (%f, %f), l_monsterPart->m_positionBase = (%f, %f), l_monsterPartPosition = (%f, %f)", l_monsterPart->m_positionDraw.x, l_monsterPart->m_positionDraw.y, l_monsterPart->m_positionBase.x, l_monsterPart->m_positionBase.y, l_monsterPartPosition.x, l_monsterPartPosition.y);
		l_monsterPart->m_size = 0.2f;
		l_monsterPart->m_angle = 0.f;
		l_monsterPart->m_angleTimer = myRandom() * 3.f;
		l_monsterPart->m_angleBase = 0.f;
		l_monsterPart = l_monsterPart->m_child;
		l_monsterPart->m_widthOnHeight = 1.f;
        l_monsterPart->m_texture = -1;
	}
	
	l_monsterPart->m_child = nil;
	m_tail = l_monsterPart;
	
	m_growTimer = 0.;
	m_hurtBreakTimer = 0.;
    m_numTexture = 1;
    m_speedGrowCoeff = 1.8f;
    m_timer = 0.;
    m_alpha = 1.f;
    m_transparency = NO;
	
	return [super init];
}

-(id)initWithPosition:(CGPoint)a_position 
			  groundY:(float)a_groundY	
			  texture:(int)a_texture 
				block:(BOOL)a_blockRoot
         transparency:(BOOL)a_transparency
            sizeLimit:(float)a_size
           numTexture:(int)a_numTexture
            growSpeed:(float)a_growSpeed
{
	[self initWithPosition:a_position groundY:a_groundY	texture:a_texture];
	m_blockRoot = a_blockRoot;
    m_transparency = a_transparency;
	m_sizeLimit = a_size;
    m_numTexture = a_numTexture;
    m_speedGrowCoeff = a_growSpeed;
	return self;
}

// Update.
-(void)Update:(NSTimeInterval)a_timeInterval position:(CGPoint)a_nextPosition
{	
    m_timer += a_timeInterval;
	m_hurtBreakTimer -= a_timeInterval;
	a_nextPosition = CGPointMake(a_nextPosition.x - m_decayPositionToLimitSpeed.x, a_nextPosition.y - m_decayPositionToLimitSpeed.y);
	float l_distance = DistancePoint(a_nextPosition, m_head->m_positionDraw);
	m_positionGoal = a_nextPosition;
	
	m_size = clip(m_sizeCoeff * l_distance, BIG_MONSTER_SIZE_MIN, m_sizeCoeff * m_sizeLimit);
	m_speedGrow = m_speedGrowCoeff * l_distance;//l_distance;
		
	// Break if we see the tail or if we are close to the target
	if(m_speedGrow > BIG_MONSTER_SPEED_GROW_LIMIT 
	   && ((m_tail->m_positionDraw.x + m_decayGrow.x + m_decayPositionToLimitSpeed.x) < -2.) 
	   && (m_hurtBreakTimer < 0.) 
	   && (Absf(a_nextPosition.x - m_head->m_positionDraw.x) > 0.5f)
	   && !m_blockRoot)
	{
	//	NSLog(@"in the very if : m_decaySpeedToLimitSpeed = (%f, %f) a_nextPosition.x = %f, m_positionDraw.x = %f\n", m_decaySpeedToLimitSpeed.x, m_decaySpeedToLimitSpeed.y, a_nextPosition.x, m_head->m_positionDraw.x );
		m_decaySpeedToLimitSpeed.x += 1.f * (a_nextPosition.x - m_head->m_positionDraw.x) * a_timeInterval;
		m_decaySpeedToLimitSpeed.y += .3f * (a_nextPosition.y - m_head->m_positionDraw.y) * a_timeInterval;
	//	printf("out the very if : m_decaySpeedToLimitSpeed = (%f, %f) a_nextPosition.x = %f, m_positionDraw.x = %f\n", m_decaySpeedToLimitSpeed.x, m_decaySpeedToLimitSpeed.y, a_nextPosition.x, m_head->m_positionDraw.x );	
		
	}
	else
	{
		m_decaySpeedToLimitSpeed.x *= max(0.f, 1.f - .4f * a_timeInterval);
		m_decaySpeedToLimitSpeed.y *= max(0.f, 1.f - .4f * a_timeInterval);
		a_nextPosition.y *= max(0.f, 1.f - .3f * a_timeInterval);
	}
	m_decayPositionToLimitSpeed.x += m_decaySpeedToLimitSpeed.x * a_timeInterval;
	m_decayPositionToLimitSpeed.y += m_decaySpeedToLimitSpeed.y * a_timeInterval;
	
	if(l_distance > 4.f)
	{
		a_nextPosition = CGPointMake(2.f * (a_nextPosition.x - m_head->m_positionDraw.x) / a_timeInterval, 2.f * (a_nextPosition.y - m_head->m_positionDraw.y) / a_timeInterval);
	}
	
	m_speedGrow = min(BIG_MONSTER_SPEED_GROW_LIMIT, m_speedGrow);
	
	m_head->m_size += m_speedGrow * a_timeInterval / (0.5f + (m_head->m_size / m_size));
	m_head->m_size = min(m_size + 0.1, m_head->m_size);
	m_head->m_positionDraw = CGPointMake(m_head->m_positionBase.x + (cos(m_head->m_angle) * m_head->m_size * BIG_MONSTER_TEXTURE_WIDTH_ON_HEIGHT), m_head->m_positionBase.y + sin(m_head->m_angle) * m_head->m_size * 1.f);
	//printf("in update : m_positionDraw = (%f, %f)\n", m_head->m_positionDraw.x, m_head->m_positionDraw.y);
	m_head->m_widthOnHeight = m_widthOnHeight;// * m_head->m_size / m_size;
	
	MonsterPart * l_monsterPartChild = m_head->m_child;
	CGPoint l_basePosition = m_head->m_positionBase;
	float l_angleParent = m_head->m_angle;
	for(int i = 1; i < MONSTER_PART_MAX; i++)
	{
		float l_moveSpeed = m_hurtBreakTimer > 0.f ? 3.f : 1.f;
		l_moveSpeed = m_blockRoot ? l_moveSpeed * 0.05f : l_moveSpeed;
		l_monsterPartChild->m_angleTimer += l_moveSpeed * a_timeInterval * (1.f + 2.f * (m_speedGrow / BIG_MONSTER_SPEED_GROW_LIMIT));
		l_monsterPartChild->m_angle = 0.25 * M_PI * sin(l_monsterPartChild->m_angleTimer) + l_monsterPartChild->m_angleBase;
		
		if((l_monsterPartChild->m_angle - l_angleParent) > BIG_MONSTER_MAX_ANGLE_DIFFERENCE)
		{
				l_monsterPartChild->m_angle = l_angleParent + BIG_MONSTER_MAX_ANGLE_DIFFERENCE;
		}
		else if((l_monsterPartChild->m_angle - l_angleParent) < -BIG_MONSTER_MAX_ANGLE_DIFFERENCE)
		{
				l_monsterPartChild->m_angle = l_angleParent - BIG_MONSTER_MAX_ANGLE_DIFFERENCE;
		}

		l_monsterPartChild->m_positionDraw = CGPointMake(l_basePosition.x - l_monsterPartChild->m_size * cos(l_monsterPartChild->m_angle) , l_basePosition.y - l_monsterPartChild->m_size * sin(l_monsterPartChild->m_angle));
		l_monsterPartChild->m_positionBase = CGPointMake(l_basePosition.x - l_monsterPartChild->m_size * cos(l_monsterPartChild->m_angle) * 2.f * DISTANCE_FROM_CHILD, l_basePosition.y - l_monsterPartChild->m_size * sin(l_monsterPartChild->m_angle) * 2.f * DISTANCE_FROM_CHILD);
		
		l_basePosition = l_monsterPartChild->m_positionBase;
		l_angleParent =  l_monsterPartChild->m_angle;
		l_monsterPartChild = l_monsterPartChild->m_child;
	}
	
	if(m_head->m_size > m_size && (!m_blockRoot || l_distance > m_size))
	{
		m_head->m_widthOnHeight = m_widthOnHeight;
		[self CreateNewHead];
	}
	
	[self draw];
}

-(void)CreateNewHead
{
	MonsterPart * l_monsterPartChild = m_head;
	CGPoint l_positionChild = m_head->m_positionBase;
	float	l_angle = m_head->m_angle;
	float	l_size = m_head->m_size;
    m_widthOnHeight += myRandom() * 0.09;
    m_widthOnHeight = clip(m_widthOnHeight, 1.f, 1.8f);
	
	for(int i = 1; i < MONSTER_PART_MAX - 1; i++)
	{
		l_monsterPartChild = l_monsterPartChild->m_child;
	}
	
	m_tail = l_monsterPartChild;
	l_monsterPartChild = m_tail->m_child;
	
	l_monsterPartChild->m_positionBase = CGPointMake(l_positionChild.x + cos(l_angle) * l_size * 2.f * DISTANCE_FROM_CHILD * BIG_MONSTER_TEXTURE_WIDTH_ON_HEIGHT, l_positionChild.y + sin(l_angle) * l_size * 2.f * DISTANCE_FROM_CHILD);
	
	l_monsterPartChild->m_angleBase = atan((l_positionChild.y - m_positionGoal.y) / (l_positionChild.x - m_positionGoal.x));
	l_monsterPartChild->m_angleBase += ((l_positionChild.x - m_positionGoal.x) < 0) ? 0.f : -M_PI;
	l_monsterPartChild->m_angleBase += myRandom() * M_PI * 0.1f;
	l_monsterPartChild->m_angleTimer = 0.f;
	
	if((l_monsterPartChild->m_angleBase - l_angle) > BIG_MONSTER_MAX_ANGLE_DIFFERENCE)
	{
		l_monsterPartChild->m_angleBase = l_angle + BIG_MONSTER_MAX_ANGLE_DIFFERENCE;
	}
	else if((l_monsterPartChild->m_angleBase - l_angle) < -BIG_MONSTER_MAX_ANGLE_DIFFERENCE)
	{
		l_monsterPartChild->m_angleBase = l_angle - BIG_MONSTER_MAX_ANGLE_DIFFERENCE;
	}
	
	l_monsterPartChild->m_angle = l_monsterPartChild->m_angleBase;
	l_monsterPartChild->m_size = 0.f;
	l_monsterPartChild->m_positionDraw = CGPointMake(l_monsterPartChild->m_positionBase.x, l_monsterPartChild->m_positionBase.y);
	l_monsterPartChild->m_child = m_head;
	l_monsterPartChild->m_texture = arc4random() % m_numTexture + m_texture;
    l_monsterPartChild->m_widthOnHeight = m_widthOnHeight;
	
	m_head = l_monsterPartChild;
}

-(void)draw
{	
	MonsterPart * l_monsterPart = m_head;
	CGPoint l_position;
    float l_alpha;
	for(int i = 0; i < MONSTER_PART_MAX; i++)
	{
        if(l_monsterPart->m_texture >= 0)
        {
            if(m_transparency)
            {
                l_alpha = 0.5 + 0.5 * pow(cos(m_timer + ((float)i / (float)MONSTER_PART_MAX) * 2.f * M_PI), 2.f);
                l_alpha *= 1.f - pow(((float)i / (float)MONSTER_PART_MAX), 2.f);
                if(i == 0)
                {
                    l_alpha *= l_monsterPart->m_size / m_size;
                }
                l_alpha *= m_alpha;
                l_alpha = clip(l_alpha, 0.f, 1.f);
            }
            else
            {
                l_alpha = 1.f;
            }
            
            l_position = CGPointMake(l_monsterPart->m_positionDraw.x + m_decayGrow.x + m_decayPositionToLimitSpeed.x, l_monsterPart->m_positionDraw.y + m_decayGrow.y + m_decayPositionToLimitSpeed.y);
            [[EAGLView sharedEAGLView] drawTextureIndex:l_monsterPart->m_texture
                                                   plan:PLAN_BACKGROUND_CLOSE
                                                   size:l_monsterPart->m_size * 1.05
                                              positionX:l_position.x
                                              positionY:l_position.y
                                              positionZ:0.
                                          rotationAngle:RADIAN_TO_DEDREE(l_monsterPart->m_angle)
                                        rotationCenterX:l_monsterPart->m_positionDraw.x
                                        rotationCenterY:l_monsterPart->m_positionDraw.y
                                           repeatNumber:1
                                          widthOnHeight:BIG_MONSTER_TEXTURE_WIDTH_ON_HEIGHT * l_monsterPart->m_widthOnHeight
                                             nightBlend:false
                                            deformation:0.f
                                               distance:-1.f
                                                 decayX:0.f
                                                 decayY:0.f
                                                  alpha:l_alpha
                                                 planFX:PLAN_BACKGROUND_SHADOW
                                                reverse:REVERSE_NONE
             ];
        }
		l_monsterPart = l_monsterPart->m_child;
	}	
}

-(void)SetDecayDraw:(CGPoint)a_decay
{
	m_decayGrow = a_decay;
}

-(void)SetAlpha:(float)a_alpha
{
	m_alpha = a_alpha;
}

-(CGPoint)GetKillPosition
{
	return CGPointMake(m_decayPositionToLimitSpeed.x + m_head->m_positionBase.x + cos(m_head->m_angle) * m_head->m_size * 2.f * DISTANCE_FROM_CHILD * BIG_MONSTER_TEXTURE_WIDTH_ON_HEIGHT,
					   m_decayPositionToLimitSpeed.y + m_head->m_positionBase.y + sin(m_head->m_angle) * m_head->m_size * 2.f * DISTANCE_FROM_CHILD
					   );
}

-(void)Hurt
{
	m_sizeCoeff *= 0.6;
	m_hurtBreakTimer = 1.f;
}

// update.
-(oneway void)release
{
	MonsterPart * l_monsterPartChild = m_head;
	MonsterPart * l_monsterPartToDelete;
	
	for(int i = 1; i < MONSTER_PART_MAX; i++)
	{
		l_monsterPartToDelete = l_monsterPartChild;
		l_monsterPartChild = l_monsterPartChild->m_child;
		free(l_monsterPartToDelete);
	}
}

@end

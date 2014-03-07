//
//  MenuScene.mm
//  H2Flow
//
//  Created by Tony Peng on 2/3/11.
//

#import "MenuScene.h"

#define PTM_RATIO 32.0

@implementation MenuScene
+(id) scene
{
#ifndef _COUNT_FPS_
	[[CCDirector sharedDirector] setDisplayFPS:NO];
#endif
	
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MenuScene *layer = [MenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
		
		self.isTouchEnabled = true;
		
		glClearColor(255,255,255,255);
		
		b2Vec2 gravity = b2Vec2(0.0f, -5.0f);
		bool doSleep = false;
		
		_MENU_WORLD = new b2World(gravity, doSleep);
		
		[self schedule:@selector(tick:)];
		
		CCSprite *bg = [CCSprite spriteWithFile:@"h2f_bg.png"];
		
		bg.position = ccp(240, 160);
		
		[self addChild:bg];
		
		/*
		for(int x = 100; x < 102; x++)
		{
			for(int y = 320; y > 200; y--)
			{
				[self menu_addWaterParticle:ccp(x, y)];
			}
		}*/
		
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"H2Flow" fontName:@"Verdana" fontSize:64];
		
		title.position = ccp(300, 250);
		title.color = ccc3(255,255,255);
		
		[self addChild: title];
		
		
	}
	
	return self;
}

-(void) tick:(ccTime) dt
{
	_MENU_WORLD->Step(dt, 10, 10);
	
	for(b2Body *b = _MENU_WORLD->GetBodyList(); b; b=b->GetNext())
	{
		if(b->GetUserData() != NULL)
		{
			CCSprite *sprite = (CCSprite *) b->GetUserData();
			
			if (b->GetPosition().y * PTM_RATIO < 0) {
				b->SetTransform(b2Vec2(b->GetPosition().x, 320 / PTM_RATIO), 0.0f);
				b->SetLinearVelocity(b2Vec2(0,0));
			}
			
			sprite.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			
			sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}
	}
}

-(void) dealloc
{
	[super dealloc];
}

-(bool) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[CCDirector sharedDirector] pause];
	[self unschedule:@selector(tick:)];
	
	[[CCDirector sharedDirector] replaceScene:[Game scene]];
	
	[[CCDirector sharedDirector] resume];
}

-(void) menu_addWaterParticle:(CGPoint)point
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	//Add the sprite
	CCSprite *water = [CCSprite spriteWithFile:@"water.png" rect:CGRectMake(0, 0, 5, 5)];
	
	water.position = point;
	
	[self addChild:water];
	
	b2Body *_body;
	
	//Create our body and shape
	b2BodyDef moleculeBodyDef;
	
	moleculeBodyDef.type = b2_dynamicBody;
	moleculeBodyDef.position.Set(point.x/PTM_RATIO, point.y/PTM_RATIO);
	moleculeBodyDef.userData = water;
	
	_body = _MENU_WORLD->CreateBody(&moleculeBodyDef);
	
	b2CircleShape circle;
	circle.m_radius = 0.5f/PTM_RATIO;
	
	b2FixtureDef ballShapeDef;
	
	ballShapeDef.shape = &circle;
	ballShapeDef.density = 50.0f;
	ballShapeDef.friction = 50.0f;
	ballShapeDef.restitution = 0.0f;
	
	_body->CreateFixture(&ballShapeDef);
}

@end

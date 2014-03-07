//
//  HelloWorldLayer.h
//  H2Flow
//
//  Created by Tony Peng on 1/23/11.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Globals.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "AccelerometerSimulation.h"
#import "CollisionListener.h"
#import "MenuScene.h"

//Should we enable debugging?
//#define _DEBUG_

//How about counting the FPS?
#define _COUNT_FPS_

// HelloWorld Layer
@interface Game : CCLayer
{
	int CURRENT_LEVEL;
	
	CCMenu *menu;
	
	CCMenuItem *finished_MenuItem;
	
	b2World *_world;
	
#ifdef _DEBUG_
	GLESDebugDraw *m_debugDraw;
#endif
	
	CollisionListener *_collisionListener;
	
	CCTMXTiledMap *_tiledMap;
	
	CCTMXLayer *_background;
	CCTMXLayer *_meta;
	
	int finish_x;
	int finish_y;
	
	int totalX;
	int totalY;
	
	int maximumMoleculesLeft;
	
	NSString *moleculesStatus;
	
	CCLabelTTF *molecules_label;
	
	bool shake_once;
}

@property (nonatomic, retain) CCTMXTiledMap *tiledMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCTMXLayer *meta;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

+(id) sceneWithLevel: (int) level;

-(id) init: (int) level;

-(void) InitWorld;

-(void) CreateFinishBlock: (float) X_LOC : (float) Y_LOC;

- (CGPoint) tileCoordForPosition: (CGPoint)pos;
- (CGPoint) positionForTileCoord: (CGPoint)tilePos;

-(void) addWaterParticle: (CGPoint)point;
@end

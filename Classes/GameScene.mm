//
//  HelloWorldLayer.m
//  H2Flow
//
//  Created by Tony Peng on 1/23/11.
//

// Import the interfaces
#import "GameScene.h"

#define PTM_RATIO 32.0

// HelloWorld implementation
@implementation Game

@synthesize tiledMap = _tiledMap;
@synthesize background = _background;
@synthesize meta = _meta;

+(id) scene
{
#ifndef _COUNT_FPS_
	[[CCDirector sharedDirector] setDisplayFPS:NO];
#endif
	
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Game *layer = [Game node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id) sceneWithLevel:(int)level
{
#ifndef _COUNT_FPS_
	[[CCDirector sharedDirector] setDisplayFPS:NO];
#endif
	
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Game *layer = [[[Game alloc] init:level] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) InitWorld
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	//Create our collision listener -- this will handle collisions!
	_collisionListener = new CollisionListener();
	
	//Create the world.
	b2Vec2 gravity = b2Vec2(0.0f, -30.0f);
	bool doSleep = false;
	
	_world = new b2World(gravity, doSleep);
	
#ifdef _DEBUG_
	m_debugDraw = new GLESDebugDraw(PTM_RATIO);
	
	_world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	
	flags += b2DebugDraw::e_shapeBit;
	
	m_debugDraw->SetFlags(flags);
#endif

	_world->SetContactListener(_collisionListener);
	
	//Create boundaries around the screen
	b2BodyDef groundBodyDef;
	
	groundBodyDef.position.Set(0,0);
	b2Body *groundBody = _world->CreateBody(&groundBodyDef);
	
	b2PolygonShape groundBox;
	b2FixtureDef boxShapeDef;
	boxShapeDef.shape = &groundBox;
	

	//Side 1 ( "bottom" of device )
	/****************************
	 *							*
	 *							*
	 *							*
	 ----------------------------
	 */
	groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateFixture(&boxShapeDef);
	
	//Side two ( "right" side of device. )
	/***************************|
	 *							|
	 *							|
	 *							|
	 ***************************|
	 */
	groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, 0), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&boxShapeDef);
	
	//Side three ( "top" of device )
	/*---------------------------
	 *							*
	 *							*
	 *							*
	 ****************************
	 */
	groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&boxShapeDef);
	
	//Last side ( "left" of device )
	/****************************
	 |							*
	 |							*
	 |							*
	 |***************************
	 */
	groundBox.SetAsEdge(b2Vec2(0, 0), b2Vec2(0, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&boxShapeDef);

	NSString *mapname = [NSString stringWithFormat:@"level_%i.tmx", CURRENT_LEVEL];
	
	self.tiledMap = [CCTMXTiledMap tiledMapWithTMXFile:mapname];
	self.background = [_tiledMap layerNamed:@"Blocks"];
	
	self.meta = [_tiledMap layerNamed:@"meta"];
	_meta.visible = NO;
	
	CGSize s = [_meta layerSize];
	
	
	for(int y=0; y < s.height;y++)
	{
		for(int _x_=0; _x_ < s.width;_x_++)
		{
			CCSprite *tile = [_meta tileAt:ccp(_x_, y)];
			
			if( tile != nil ) {
				b2Body *_body;
				
				//Create our body and shape
				b2BodyDef tileBodyDef;
				
				int _x = tile.position.x + 16;
				int y = tile.position.y + 16;
				
				
				tileBodyDef.type = b2_staticBody;
				tileBodyDef.position.Set(_x / PTM_RATIO, y / PTM_RATIO);
				//tileBodyDef.isGravitated = NO;
				//tileBodyDef.userData = tile;
				
				_body = _world->CreateBody(&tileBodyDef);
				
				b2PolygonShape blockShape;
				
				blockShape.SetAsBox(16 /PTM_RATIO, 16 /PTM_RATIO);
				
				b2FixtureDef blockShapeDef;
				
				blockShapeDef.shape = &blockShape;
				blockShapeDef.density = 10.0f;
				blockShapeDef.friction = 10.0f;
				blockShapeDef.restitution = 0.0f;
				
				_body->CreateFixture(&blockShapeDef);
			}
		}
	}
									
	[self addChild:_tiledMap z:-1];
	//Schedule a tick method to update our physics.
	[self schedule:@selector(tick:)];
}

-(CGPoint)tileCoordForPosition:(CGPoint)pos
{
	int x = pos.x / _tiledMap.tileSize.width;
    int y = ((_tiledMap.mapSize.height * _tiledMap.tileSize.height) - pos.y) / _tiledMap.tileSize.height;
    return ccp(x, y);
}
		
-(CGPoint)positionForTileCoord: (CGPoint) tilePos
{
	int x = tilePos.x * _tiledMap.tileSize.width;
	int y = tilePos.y * _tiledMap.tileSize.height;
	
	return ccp(x,y);
}

-(void) CreateFinishBlock:(float)X_LOC :(float)Y_LOC
{
	b2Body *_body;
	
	//Create our body and shape
	b2BodyDef tileBodyDef;
	
	float _x = X_LOC;
	float y = Y_LOC;
	
	tileBodyDef.type = b2_staticBody;
	tileBodyDef.position.Set(_x / PTM_RATIO, y / PTM_RATIO);
	tileBodyDef.triggersBodyDeletionUponImpact = YES;
	//tileBodyDef.isGravitated = NO;
	//tileBodyDef.userData = tile;
	
	_body = _world->CreateBody(&tileBodyDef);
	
	b2PolygonShape blockShape;
	
	blockShape.SetAsBox(16 /PTM_RATIO, 16 /PTM_RATIO);
	
	b2FixtureDef blockShapeDef;
	
	blockShapeDef.shape = &blockShape;
	blockShapeDef.density = 10.0f;
	blockShapeDef.friction = 0.0f;
	blockShapeDef.restitution = 0.0f;
	
	_body->CreateFixture(&blockShapeDef);
	
}

-(id) init: (int) level
{
	if( (self=[super init] )) {
		
		CURRENT_LEVEL = level;
		
		self.isAccelerometerEnabled = YES;
		
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];

		shake_once = false;
		
		glClearColor(255,255,255,255);
		
		[self InitWorld];
		
		CCTMXObjectGroup *objects = [_tiledMap objectGroupNamed:@"Player props"];
		NSAssert(objects != nil, @"Could not find objects in map");
		
		NSMutableDictionary *spawnPoint = [objects objectNamed:@"spawn"];
		NSAssert(spawnPoint != nil, @"Could not find a valid spawn!");
		
		NSMutableDictionary *finishPoint = [objects objectNamed:@"finish"];
		NSAssert(finishPoint != nil, @"Could not find a valid finish location!");
		
		NSMutableDictionary *waterProps = [objects objectNamed:@"waterProps"];
		NSAssert(waterProps != nil, @"Could not find valid properties!");
		
		NSMutableDictionary *label1Props = [objects objectNamed:@"label1"];
		
		int l1_x, l1_y, l1_fontsize, l1_offset_x, l1_offset_y;
		
		NSString *l1_text;
		
		if(label1Props != nil)
		{
			l1_offset_x = [[label1Props valueForKey:@"offset_x"] intValue];
			l1_offset_y = [[label1Props valueForKey:@"offset_y"] intValue];
			
			l1_x = [[label1Props valueForKey:@"x"] intValue] + l1_offset_x;
			l1_y = [[label1Props valueForKey:@"y"] intValue] + l1_offset_y;
			
			l1_fontsize = [[label1Props valueForKey:@"fontsize"] intValue];
			
			l1_text = (NSString *)[label1Props valueForKey:@"content"];
		}
		else
		{
			l1_offset_x = -1;
			l1_offset_y = -1;
			
			l1_x = -1;
			l1_y = -1;
			
			l1_fontsize = -1;
			
			l1_text = nil;
		}
		
		if(l1_offset_x != -1 && l1_offset_y != -1 && l1_x != -1 && l1_y != -1 && l1_fontsize != -1 && l1_text != nil)
		{
			CCLabelTTF *label = [CCLabelTTF labelWithString:l1_text fontName:@"Helvetica" fontSize:l1_fontsize];
			
			label.color = ccc3(0,0,0);
			
			label.position = ccp(l1_x, l1_y);
			
			[self addChild:label];
		}
		
		int x_ = [[spawnPoint valueForKey:@"x"] intValue];
		int y_ = [[spawnPoint valueForKey:@"y"] intValue];
		
		finish_x = [[finishPoint valueForKey:@"x"] floatValue];
		finish_y = [[finishPoint valueForKey:@"y"] floatValue];
		
		totalX = [[waterProps valueForKey:@"x_length"] intValue];
		totalY = [[waterProps valueForKey:@"y_length"] intValue];
		
		//We want at LEAST 85% of the water to have reached the pipe. (ceil it if it isn't a whole)
		int total = totalX * totalY;
		
		maximumMoleculesLeft = ceil(total * 0.15);
		
		moleculesStatus = [NSString stringWithFormat:@"0 / %d", maximumMoleculesLeft];
		
		molecules_label = [CCLabelTTF labelWithString:moleculesStatus fontName:@"Helvetica" fontSize:16];
		
		molecules_label.color = ccc3(0,0,255);
		
		molecules_label.position = ccp(375, 275);
		
		[self addChild:molecules_label];
		
		//Create the finish block
		
		[self CreateFinishBlock:finish_x :finish_y];
		
		for(int _x = x_; _x < x_ + totalX; _x++)
		{
			for(int _y=y_; _y<y_ + totalY; _y++)
			{
				[self addWaterParticle:ccp(_x,_y)];
			}
		}
	}
	
	finished_MenuItem = [CCMenuItemImage
									itemFromNormalImage:@"level_done.png" selectedImage:@"level_done.png"
									target:self selector:@selector(doneButtonTapped:)];
	
	finished_MenuItem.position = ccp(432, 16);
	
	finished_MenuItem.visible = NO;
	
	menu = [CCMenu menuWithItems:finished_MenuItem, nil];
	
	menu.position = CGPointZero;
	
	[self addChild:menu];
	
	return self;	
}

// on "init" you need to initialize your instance
-(id) init/*: NSString mapLocation*/
{
	return [self init: 1];
}

#ifdef _DEBUG_
-(void) draw
{
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	_world->DrawDebugData();
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}
#endif

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{	
	//for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext())
	//{
	//	if(b->GetUserData() != NULL)
	//	{
	//		b = NULL;
	//	}
	//}
	
	//delete _world;
	//_world = NULL;
	
#ifdef _DEBUG_
	//delete m_debugDraw;
	//m_debugDraw = NULL;
#endif
	
	//delete _collisionListener;
	//_collisionListener = NULL;
	
	//self.tiledMap = nil;
	//self.background = nil;
	
	//self.meta = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{	
	b2Vec2 gravity(-acceleration.y * 15, -30.0f/*acceleration.x * 15*/);

	_world->SetGravity(gravity);
	
	//Check for shake
	float THRESHOLD = 1.75;
	
	if (acceleration.x > THRESHOLD || acceleration.x < -THRESHOLD || 
		acceleration.y > THRESHOLD || acceleration.y < -THRESHOLD ||
		acceleration.z > THRESHOLD || acceleration.z < -THRESHOLD) {
		
		if (!shake_once) {
			//Apply linear impulse
			DbgPrint(@"Shook!");
			
			for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext())
			{
				if(b->GetUserData() != nil)
				{
					CCSprite *sprite = (CCSprite *)b->GetUserData();
					
					float m = -acceleration.y;
					
					if(m > 0.15f)
						m = 0.15f;
					
					if(m < -0.15f)
						m = -0.15f;
					
					b2Vec2 force = b2Vec2(m / 15, 0.025);
					
					if(sprite.tag == -1)
					{
						b->ApplyLinearImpulse(force, b->GetWorldCenter());
					}
				}
			}
			
			shake_once = true;
		}
		
	}
	else {
		shake_once = false;
	}
}

-(void) addWaterParticle:(CGPoint)point
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
	
	_body = _world->CreateBody(&moleculeBodyDef);
	
	b2CircleShape circle;
	circle.m_radius = 1/PTM_RATIO;
	
	b2FixtureDef ballShapeDef;
	
	ballShapeDef.shape = &circle;
	ballShapeDef.density = 1.0f;
	ballShapeDef.friction = 0.5f;
	ballShapeDef.restitution = 0.0f;
	
	_body->CreateFixture(&ballShapeDef);
}

-(void) doneButtonTapped:(id) sender
{
	
	[[CCDirector sharedDirector] pause];
	UIAlertView *dialog = [UIAlertView new];
	
	dialog.tag = 100;
	
	[dialog setDelegate:self];
	[dialog setTitle:@"Congratulations!"];
	[dialog setMessage:@"You have successfully completed the level."];
	[dialog addButtonWithTitle:@"Continue"];
	[dialog addButtonWithTitle:@"Replay"];
	[dialog show];
	[dialog release];
}

-(void) tick:(ccTime) dt
{
	_world->Step(dt, 10,10);
	
	int molecules = 0;
	
	for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext())
	{
		if(b->GetUserData() != NULL)
		{
			CCSprite *sprite = (CCSprite *) b->GetUserData();
			
			sprite.position =
				ccp(b->GetPosition().x * PTM_RATIO,
					b->GetPosition().y * PTM_RATIO);
			sprite.rotation = -1
				 * CC_RADIANS_TO_DEGREES(
					b->GetAngle()
				);
			
			if(sprite.tag == -1)
				molecules++;
		}
	}
	
	//NSLog(@"Molecules: %i", molecules);
	
	std::vector<b2Body *>toDestroy;
	std::vector<Collision>::iterator pos;
	
	for(pos=_collisionListener->_contacts.begin();
		pos != _collisionListener->_contacts.end();
		++pos)
	{
		Collision collision = *pos;
		
		b2Body *bodyA = collision.fixtureA->GetBody();
		b2Body *bodyB = collision.fixtureB->GetBody();

		
		if(bodyA->TriggersRemoval() && !bodyB->TriggersRemoval())
		{
			if(bodyB->GetUserData() != NULL)
			{
				if(std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end())
					toDestroy.push_back(bodyB);
			}
		}
		else if(!bodyA->TriggersRemoval() && bodyB->TriggersRemoval())
		{
			if(bodyA->GetUserData() != NULL)
			{
				if(std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end())
					toDestroy.push_back(bodyA);
			}
		}
	}
	
	std::vector<b2Body *>::iterator pos2;
	
	for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2)
	{
		b2Body *body = *pos2;
		
		[self removeChild:(CCSprite *)body->GetUserData() cleanup:YES];
		
		_world->DestroyBody(body);
	}
	
	moleculesStatus = [NSString stringWithFormat:@"%i / %i", molecules, maximumMoleculesLeft];
	
	[molecules_label setString:moleculesStatus];
	
	if(molecules == 0)
	{
		[[CCDirector sharedDirector] pause];
		UIAlertView *dialog = [UIAlertView new];
		
		dialog.tag = 100;
		
		[dialog setDelegate:self];
		[dialog setTitle:@"Congratulations!"];
		[dialog setMessage:@"You have successfully completed the level."];
		[dialog addButtonWithTitle:@"Continue"];
		[dialog addButtonWithTitle:@"Replay"];
		[dialog show];
		[dialog release];
	}
	else if(molecules <= maximumMoleculesLeft)
	{
		moleculesStatus = [NSString stringWithFormat:@"Finished! (%i remaining)", molecules];
		
		[molecules_label setString:moleculesStatus];
		
		finished_MenuItem.visible = YES;
	}
}

-(void)alertView :(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 100)
	{
		if(buttonIndex==0){
			@try {
				[self unschedule:@selector(tick:)];
				[self retain];
			
				[[CCDirector sharedDirector] replaceScene:[Game sceneWithLevel:CURRENT_LEVEL + 1]];
			
				[[CCDirector sharedDirector] resume];
			}
			@catch (NSException * e) {
				[[CCDirector sharedDirector] pause];
				UIAlertView *dialog = [UIAlertView new];
				
				dialog.tag = 101;
				
				[dialog setDelegate:self];
				[dialog setTitle:@"Congratulations!"];
				[dialog setMessage:@"You have completed the final level!  Stay tuned for updates and level packs!"];
				[dialog addButtonWithTitle:@"Continue"];
				[dialog show];
				[dialog release];
			}
		}
		else if(buttonIndex==1){
		
			[self unschedule:@selector(tick:)];
			[self retain];
		
			[[CCDirector sharedDirector] replaceScene:[Game sceneWithLevel:CURRENT_LEVEL]];
		
			NSLog(@"replay");
		
			[[CCDirector sharedDirector] resume];
		}
	}
	else if (alertView.tag == 101)//End of level pack
	{
		[[CCDirector sharedDirector] pause];
		[self unschedule:@selector(tick:)];
		
		[[CCDirector sharedDirector] replaceScene:[MenuScene scene]];
		
		[[CCDirector sharedDirector] resume];
	}
}

@end

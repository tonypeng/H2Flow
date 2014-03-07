//
//  MenuScene.h
//  H2Flow
//
//  Created by Tony Peng on 2/3/11.
//

#import <Foundation/Foundation.h>
#import "GameScene.h"

@interface MenuScene : CCLayer {
	b2World *_MENU_WORLD;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

-(void) menu_addWaterParticle:(CGPoint)point;

@end

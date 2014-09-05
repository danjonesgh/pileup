//
//  HelloWorldLayer.h
//  PileUp
//
//  Created by Dan Jones on 10/17/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    b2Body *body;
    b2Body *blockBody;
    b2Body *groundBody;
    b2MouseJoint *mouseJoint;
    b2Vec2 megaTouchPoint;
    CGPoint startPoint;
    CCNode *blockObj;
    
    NSMutableArray *objectsOnBoard;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

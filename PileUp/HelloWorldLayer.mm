//
//  HelloWorldLayer.mm
//  PileUp
//
//  Created by Dan Jones on 10/17/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "Box.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
    kTagBall = 1,
};


// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
//		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		//b2Body* groundBody = world->CreateBody(&groundBodyDef);
		groundBody = world->CreateBody(&groundBodyDef);
        
		// Define the ground box shape.
		b2PolygonShape groundBox;		
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// top
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
		groundBody->CreateFixture(&groundBox,0);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);

        

        objectsOnBoard = [[NSMutableArray alloc] init];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap for a ball"
                                               fontName:@"Arial" fontSize:20];
		
        [self addChild:label z:0];
		[label setColor:ccc3(255,255,255)];
		
        label.position = ccp( screenSize.width/5, screenSize.height-25);
		
        // Standard method to create a button
        CCMenuItem *starMenuItem = [CCMenuItemImage itemFromNormalImage:@"bluedotnew-scaled40.png"
                                                          selectedImage:@"bluedotnew-scaled40.png"
                                                                 target:self
                                                               selector:@selector(circleButtonTapped:)];
        
        starMenuItem.position = ccp( screenSize.width/5, screenSize.height-55);
        
        CCMenuItem *barMenuItem = [CCMenuItemImage itemFromNormalImage:@"green-bar.png"
                                                         selectedImage:@"green-bar.png"
                                                                target:self
                                                              selector:@selector(barButtonTapped:)];
        
        barMenuItem.position = ccp( screenSize.width/2, screenSize.height-55);
        
        
        
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, barMenuItem, nil];
        starMenu.position = CGPointZero;
        [self addChild:starMenu];
        

        
        
        CCSprite *greenbar = [CCSprite spriteWithFile:@"green-bar.png" rect:CGRectMake(0, 0, 80, 20)];
        greenbar.position = ccp(220, 320);
        [self addChild:greenbar];
        
        b2BodyDef bd;
        bd.type = b2_dynamicBody;
        bd.position.Set(220/PTM_RATIO, 320/PTM_RATIO);
        bd.userData = greenbar;
        bd.allowSleep = false;
        b2Body *body2 = world->CreateBody(&bd);
        //b2PolygonShape shape;
        //shape.SetAsBox(.5f, .5f);
        b2PolygonShape shape2;
        shape2.SetAsBox(greenbar.contentSize.width/PTM_RATIO/2, greenbar.contentSize.height/PTM_RATIO/2);
        
        
        b2FixtureDef fixDef2;
        fixDef2.shape = &shape2;
        fixDef2.density = 1.0f;
        fixDef2.friction = 0.6f;
        body2->CreateFixture(&fixDef2);
        
		[self schedule: @selector(tick:)];
	}
	return self;
}

- (void)barButtonTapped:(id)sender
{
    CCNode *box = [Box createBox];
    box.position = ccp(100, 100);
    //box.sprite.position = ccp(100,100);
    [self addChild:box];
    
    NSLog(@"tapped button bar");
    //CCSprite *sprite = (CCSprite*) [self getChildByTag:kTagBall];
    CCSprite *greenbar = [CCSprite spriteWithFile:@"green-bar.png" rect:CGRectMake(0, 0, 80, 20)];
    greenbar.position = ccp(220, 320);
    [self addChild:greenbar];
    
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    bd.position.Set(220/PTM_RATIO, 320/PTM_RATIO);
    bd.userData = greenbar;
    bd.allowSleep = false;
    b2Body *body1 = world->CreateBody(&bd);
    //b2PolygonShape shape;
    //shape.SetAsBox(.5f, .5f);
    b2PolygonShape shape;
    shape.SetAsBox(greenbar.contentSize.width/PTM_RATIO/2, greenbar.contentSize.height/PTM_RATIO/2);
    
    
    b2FixtureDef fixDef;
    fixDef.shape = &shape;
    fixDef.density = 1.0f;
    fixDef.friction = 0.6f;
    body1->CreateFixture(&fixDef);
    
    //[objectsOnBoard addObject:greenbar];
    
}

- (void)circleButtonTapped:(id)sender
{
    NSLog(@"tapped button cr");
    //CCSprite *sprite = (CCSprite*) [self getChildByTag:kTagBall];
    CCSprite *sprite1 = [CCSprite spriteWithFile:@"bluedotnew-scaled2.png" rect:CGRectMake(0, 0, 80, 80)];
    sprite1.position = ccp(120, 320);
    
    b2BodyDef bodyDef1;
    bodyDef1.type = b2_dynamicBody;
    bodyDef1.position.Set(120/PTM_RATIO, 320/PTM_RATIO);
    bodyDef1.userData = sprite1;
    b2Body *body1 = world->CreateBody(&bodyDef1);
    //b2PolygonShape shape;
    //shape.SetAsBox(.5f, .5f);
    b2CircleShape shape;
    shape.m_radius = (40/PTM_RATIO);
    
    b2FixtureDef fixDef;
    fixDef.shape = &shape;
    fixDef.density = 1.0f;
    fixDef.friction = 0.6f;
    //fixDef.restitution = 0.8f;
    body1->CreateFixture(&fixDef);
    [self addChild:sprite1];
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    startPoint = location;
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            if(CGRectContainsPoint(myActor.boundingBox, location))
            {
                body = b;
                break;
            }
		}
	}

    
    b2Vec2 touchLocation = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    NSLog(@" t %f, ok %f", touchLocation.x, touchLocation.y);
    if(body != nil)
    {
        if(mouseJoint){
            world->DestroyJoint(mouseJoint);
            mouseJoint = NULL;
        }
        b2MouseJointDef md;
        md.bodyA = groundBody;
        md.bodyB = body;
        md.target = b2Vec2(touchLocation.x, touchLocation.y);
        // md.collideConnected = true;
        md.maxForce = 1000.0f * body->GetMass();
        md.dampingRatio = 1;
        md.frequencyHz = 1.5f;
        mouseJoint = (b2MouseJoint*)world->CreateJoint(&md);
        
    }
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    //CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
   
    //megaTouchPoint = b2Vec2(location.x * PTM_RATIO, location.y * PTM_RATIO);
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            if(CGRectContainsPoint(myActor.boundingBox, location))
            {
             
              //  NSLog(@"y pos %f %f", location.y, location.y/PTM_RATIO);
                //b->SetLinearVelocity(b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO));
               // b->SetTransform(b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO), 0);
                //myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                mouseJoint->SetTarget(b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO));
            }
            myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}
	}
}



-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}




-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            //NSLog(@"my ac %@", myActor);
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            //b->SetLinearVelocity(megaTouchPoint);
            //b->SetTransform(b2Vec2(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO),0);
        }
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
        if(mouseJoint){
            world->DestroyJoint(mouseJoint);
            mouseJoint = NULL;
        }


		//[self addNewSpriteWithCoords: location];
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [objectsOnBoard release];
    objectsOnBoard = nil;
    
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end

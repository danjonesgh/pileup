//
//  Box.h
//  PileUp
//
//  Created by Dan Jones on 11/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Box : CCNode 
    


@property (nonatomic, retain) CCSprite *sprite;
//@property (nonatomic, retain) b2Body *body;

+ (CCNode *)createBox;

@end

//
//  Box.m
//  PileUp
//
//  Created by Dan Jones on 11/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Box.h"


@implementation Box

@synthesize sprite = _sprite;

- (CCSprite *)sprite
{
    
    if(!_sprite) return [CCSprite spriteWithFile:@"green-bar.png"];
    else return _sprite;
}

+ (CCNode *)createBox
{
    return [[[self class] alloc] init];
}

@end

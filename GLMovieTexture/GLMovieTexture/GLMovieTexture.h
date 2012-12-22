//
//  GLMovieTexture.h
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EAGLContext;

@interface GLMovieTexture : NSObject
@property (readonly) uint32_t textureId;
@property (readonly) uint32_t subTextureId;
@property (readonly) int width;
@property (readonly) int height;
@property (readonly) int format;
-(id)initWithMovie:(NSString*)path context:(EAGLContext*)context;
-(void)play;
-(void)pause;
-(void)stop;
@end

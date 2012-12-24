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
@property (assign,nonatomic) BOOL loop;
@property (assign,nonatomic) float currentTime;
@property (assign,nonatomic) uint32_t targetTextureId;
-(id)initWithMovie:(NSString*)path context:(EAGLContext*)context;
-(void)setMovie:(NSString*)path;
-(void)setGLContext:(EAGLContext*)context;
-(void)setTargetTextureId:(uint32_t)textureId;
-(void)play;
-(void)pause;
-(void)stop;
@end

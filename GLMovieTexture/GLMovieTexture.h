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
@property (assign) uint32_t textureId;
@property (readonly) int width;
@property (readonly) int height;
@property (readonly) int format;
@property (assign,nonatomic) BOOL loop;
@property (assign,nonatomic) float currentTime;
@property (readonly,nonatomic) BOOL isPlaying;
-(id)initWithMovie:(NSString*)path context:(EAGLContext*)context;
-(void)setMovie:(NSString*)path;
-(void)setGLContext:(EAGLContext*)context;
-(void)play;
-(void)pause;
-(void)stop;
@end

//
//  GLMovieTextureOSX.h
//  GLMovieTexture
//
//  Created by hayashi on 1/7/13.
//  Copyright (c) 2013 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGL/OpenGL.h>

@interface EAGLContext : NSObject{
@public
	void *_context;
}
+(EAGLContext*)currentContext;
+(void)setCurrentContext:(EAGLContext*)context;
@end



@interface GLMovieTextureOSX : NSObject{
	uint32_t       _targetTextureId;
	uint32_t       _textureId;
	EAGLContext   *_context;
	EAGLContext   *_mainContext;
	MovieDecoder  *_decoder;
	int            _format;
	int            _width;
	int            _height;
	int            _displayWidth;
	BOOL           _initFlag;
	GLFBOTexture  *_fboTexture;
}
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

typedef GLMovieTextureOSX GLMovieTexture;

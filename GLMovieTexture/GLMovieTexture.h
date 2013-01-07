//
//  GLMovieTexture.h
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

typedef struct{
	uint32_t textureId;
	uint32_t format;
	void    *data;
}GLTextureInfo;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@class EAGLContext;
#else
@interface EAGLContext : NSObject{
@public
	void *_context;
}
+(EAGLContext*)currentContext;
+(void)setCurrentContext:(EAGLContext*)context;
-(id)initWithAPI:(int)api sharegroup:(void*)context;
-(int)API;
-(void*)sharegroup;
@end
typedef void *CVOpenGLESTextureRef;
typedef void *CVOpenGLESTextureCacheRef;
#endif

@class MovieDecoder;
@class GLFBOTexture;
@class GLImageShader;

@interface GLMovieTexture : NSObject{
	uint32_t       _targetTextureId;
	uint32_t       _texNum;
	EAGLContext   *_context;
	EAGLContext   *_mainContext;
	MovieDecoder  *_decoder;
	int            _format;
	int            _width;
	int            _height;
	int            _displayWidth;
	BOOL           _initFlag;
	GLFBOTexture  *_fboTexture;
	GLImageShader *_imageShader;
	GLTextureInfo  _textures[2];
	CVOpenGLESTextureCacheRef _textureCache;
	CVOpenGLESTextureRef _textureRef[2];
	uint32_t       _textureId;
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


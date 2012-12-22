//
//  GLMovieTexture.m
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import "GLMovieTexture.h"
#import "MovieDecoder.h"
#import "GLYUVRenderer.h"
#import "GLFBOTexture.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GLMovieTexture () <MovieDecoderDelegate>{
	uint32_t       _textureId;
	uint32_t       _subTextureId;
	EAGLContext   *_context;
	MovieDecoder  *_decoder;
	int            _format;
	int            _width;
	int            _height;
	BOOL           _initFlag;
	GLFBOTexture  *_fboTexture;
	GLYUVRenderer *_yuvRenderer;
}
@end

@implementation GLMovieTexture

@synthesize subTextureId = _subTextureId;
@synthesize width = _width;
@synthesize height = _height;
@synthesize format = _format;

-(id)initWithMovie:(NSString*)path context:(EAGLContext*)context{
	self = [super init];
	_format = '420f'; // 4.4msec
	//_format = 'BGRA';  // 5.5msec
	[self setGLContext:context];
	[self setMovie:path];
	return self;
}

- (void)dealloc
{
	[_fboTexture release];
	[_yuvRenderer release];
    [_decoder release];
	[_context release];
    [super dealloc];
}

-(uint32_t)textureId{
	if( _fboTexture ){
		return _fboTexture.textureId;
	}
	return _textureId;
}

-(void)setMovie:(NSString*)path{
	[_fboTexture release];
	_fboTexture = nil;
	[_decoder release];
	_decoder = [[MovieDecoder alloc] initWithMovie:path format:_format];
	_decoder.delegate = self;
	_width = _decoder.width;
	_height = _decoder.height;
}

-(void)setGLContext:(EAGLContext*)context{
	[_yuvRenderer release];
	_yuvRenderer = nil;
	[_fboTexture release];
	_fboTexture = nil;
	[_context release];
	[EAGLContext setCurrentContext:context];
	_textureId = [self createTexture];
	if( _format=='420v' || _format=='420f' ){
		_subTextureId = [self createTexture];
		_yuvRenderer = [[GLYUVRenderer alloc] init];
	}
	_context = [[EAGLContext alloc] initWithAPI:context.API sharegroup:context.sharegroup];
}

-(void)play{
	if( [_decoder isRunning] ){
		[_decoder stop];
	}
	_initFlag = NO;
	[_decoder start];
}

-(void)pause{
	if( [_decoder isRunning] ){
		[_decoder pause];
	}
}

-(void)stop{
	[_decoder stop];
}

-(void)movieDecoderDecodeFrame:(MovieDecoder *)decoder buffers:(void**)buffers{
	[EAGLContext setCurrentContext:_context];
	int w = decoder.width;
	int h = decoder.height;
	if( _format == 'BGRA' ){
		glBindTexture(GL_TEXTURE_2D, _textureId);
		if( !_initFlag ){
			_initFlag = YES;
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0,
						 GL_BGRA, GL_UNSIGNED_BYTE, buffers[0]);
		}else{
			glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_BGRA, GL_UNSIGNED_BYTE, buffers[0]);
		}
		glBindTexture(GL_TEXTURE_2D, 0);
	}else{
		glBindTexture(GL_TEXTURE_2D, _textureId);
		if( !_initFlag ){
			_initFlag = YES;
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, w, h, 0,
						 GL_LUMINANCE, GL_UNSIGNED_BYTE, buffers[0]);
			glBindTexture(GL_TEXTURE_2D, _subTextureId);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, w/2, h/2, 0,
						 GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, buffers[1]);
			_fboTexture = [[GLFBOTexture alloc] initWithSize:CGSizeMake(w,h)];
		}else{
			glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_LUMINANCE, GL_UNSIGNED_BYTE, buffers[0]);
			glBindTexture(GL_TEXTURE_2D, _subTextureId);
			glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w/2, h/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, buffers[1]);
			[_fboTexture bind];
			[_yuvRenderer renderWithTexture:_textureId uvTexture:_subTextureId];
			[_fboTexture unbind];
		}
		glBindTexture(GL_TEXTURE_2D, 0);
	}
	glFlush();
}

-(void)movieDecoderDecodeFinished:(MovieDecoder *)decoder{
	NSLog(@"Finished!");
}

-(uint32_t)createTexture{
	uint32_t textureId = 0;
	glGenTextures(1,&textureId);
	glBindTexture(GL_TEXTURE_2D,textureId);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glBindTexture(GL_TEXTURE_2D,0);
	return textureId;
}

@end


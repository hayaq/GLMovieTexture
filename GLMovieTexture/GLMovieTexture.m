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

#define DECODE_FORMAT '420v'

// (iPhone5)
// '420v' '420f' : 4.4msec
// 'BGRA' : 5.5msec

@interface GLMovieTexture () <MovieDecoderDelegate>{
	uint32_t       _textureId;
	uint32_t       _subTextureId;
	uint32_t       _targetTextureId;
	EAGLContext   *_context;
	EAGLContext   *_mainContext;
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

-(id)init{
	self = [super init];
	_format = DECODE_FORMAT;
	return self;
}

-(id)initWithMovie:(NSString*)path context:(EAGLContext*)context{
	self = [super init];
	_format = DECODE_FORMAT;
	[self setGLContext:context];
	[self setMovie:path];
	return self;
}


- (void)dealloc{
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
	_initFlag = NO;
	[_fboTexture release];
	_fboTexture = nil;
	[_decoder release];
	_decoder = [[MovieDecoder alloc] initWithMovie:path format:_format];
	_decoder.delegate = self;
	_width = _decoder.width;
	_height = _decoder.height;
}

-(void)setGLContext:(EAGLContext*)context{
	_initFlag = NO;
	_mainContext = [context retain];
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

-(uint32_t)targetTextureId{
	if( _targetTextureId == 0 ){
		return _textureId;
	}
	return _targetTextureId;
}

-(void)setTargetTextureId:(uint32_t)textureId{
	_initFlag = NO;
	_targetTextureId = textureId;
}

-(void)play{
	if( ![_decoder isRunning] ){
		[_decoder start];
	}
}

-(void)pause{
	if( [_decoder isRunning] ){
		[_decoder pause];
	}
}

-(void)stop{
	[_decoder stop];
}

-(float)currentTime{
	return (float)_decoder.currentTime;
}

-(void)setCurrentTime:(float)t{
	[_decoder setCurrentTime:t];
}

-(BOOL)loop{
	return _decoder.loop;
}

-(void)setLoop:(BOOL)loop{
	_decoder.loop = loop;
}

-(void)movieDecoderDecodeFrame:(MovieDecoder *)decoder buffers:(void**)buffers{
	[EAGLContext setCurrentContext:_context];
	int w = decoder.width;
	int h = decoder.height;
	if( _format == 'BGRA' ){
		glBindTexture(GL_TEXTURE_2D, _targetTextureId? _targetTextureId : _textureId);
		if( !_initFlag ){
			_initFlag = YES;
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0,
						 GL_BGRA, GL_UNSIGNED_BYTE, buffers[0]);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
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
			if( _targetTextureId ){
				_fboTexture = [[GLFBOTexture alloc] initWithTextureId:_targetTextureId size:CGSizeMake(w,h)];
			}else{
				_fboTexture = [[GLFBOTexture alloc] initWithSize:CGSizeMake(w,h)];
			}
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
	[EAGLContext setCurrentContext:_mainContext];
}

-(void)movieDecoderDecodeFinished:(MovieDecoder *)decoder{
	
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


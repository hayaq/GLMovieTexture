//
//  GLMovieTextureOSX.m
//  GLMovieTexture
//
//  Created by hayashi on 1/7/13.
//  Copyright (c) 2013 hayashi. All rights reserved.
//
#import "GLMovieTexture.h"
#import "MovieDecoder.h"
#import "GLFBOTexture.h"

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#define DECODE_FORMAT 'BGRA'

@interface GLMovieTexture () <MovieDecoderDelegate>
@end

@implementation GLMovieTexture

@synthesize width = _displayWidth;
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
	[_decoder stop];
	_decoder.delegate = nil;
	[_decoder release];
	[_context release];
	[super dealloc];
}

-(uint32_t)textureId{
	return 0;
}

-(void)setMovie:(NSString*)path{
	_initFlag = NO;
	[_decoder release];
	_decoder = [[MovieDecoder movieDecoderWithMovie:path format:_format] retain];
	_width = 0;
	_height = 0;
}

-(void)setGLContext:(EAGLContext*)context{
	if( !context ){
		[_mainContext release];
		_mainContext = nil;
		[_context release];
		_context = nil;
		[_fboTexture release];
		_fboTexture = nil;
		return;
	}
	[_fboTexture release];
	_fboTexture = nil;
	_initFlag = NO;
	_mainContext = [context retain];
	[_context release];
	[EAGLContext setCurrentContext:_mainContext];
	_context = [[context makeShareContext] retain];
}

-(void)setTextureId:(uint32_t)textureId{
	_initFlag = NO;
	_targetTextureId = textureId;
}

-(void)play{
	if( ![_decoder isRunning] ){
		_decoder.delegate = self;
		[_decoder start];
	}
}

-(void)pause{
	[_decoder pause];
}

-(void)stop{
	[_decoder stop];
	_decoder.delegate = nil;
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

-(BOOL)isPlaying{
	return _decoder.isRunning;
}

-(void)movieDecoderDidDecodeFrame:(MovieDecoder *)decoder pixelBuffer:(CVPixelBufferRef)pixBuff{
	if( _format != 'BGRA' ){ return; }
	[EAGLContext setCurrentContext:_context];
	
	CVPixelBufferLockBaseAddress(pixBuff, 0);
	void *buff = CVPixelBufferGetBaseAddress(pixBuff);
	if( !_initFlag ){
		_initFlag = YES;
		_width = CVPixelBufferGetBytesPerRow(pixBuff)/4;
		_height = CVPixelBufferGetHeight(pixBuff);
		_displayWidth = CVPixelBufferGetWidth(pixBuff);
		_fboTexture = [[GLFBOTexture alloc] initWithTextureId:_targetTextureId size:CGSizeMake(_width,_height)];
		glGenTextures(1,&_textureId);
		glBindTexture(GL_TEXTURE_2D, _textureId);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_BGRA, GL_UNSIGNED_BYTE, buff);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
	}else{
		glBindTexture(GL_TEXTURE_2D, _textureId);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, _width, _height, GL_BGRA, GL_UNSIGNED_BYTE, buff);
	}
	CVPixelBufferUnlockBaseAddress(pixBuff, 0);
	
	[_fboTexture bind];
	[self drawTexture];
	glFlush();
	[_fboTexture unbind];
	
	[EAGLContext setCurrentContext:_mainContext];
}

-(void)movieDecoderDidFinishDecoding:(MovieDecoder *)decoder{
	
}

-(void)drawTexture{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, _textureId);
	glColor4f(1, 1, 1, 1);
	glBegin(GL_QUADS);
	glTexCoord2f(0, 1); glVertex2f(-1, -1);
	glTexCoord2f(1, 1); glVertex2f(+1, -1);
	glTexCoord2f(1, 0); glVertex2f(+1, +1);
	glTexCoord2f(0, 0); glVertex2f(-1, +1);
	glEnd();
	glBindTexture(GL_TEXTURE_2D, 0);
	glDisable(GL_TEXTURE_2D);
}

@end

@implementation EAGLContext

-(id)init{
	self = [super init];
	_context = CGLGetCurrentContext();
	if( _context ){
		CGLRetainContext(_context);
	}
	return self;
}

-(id)initWithContext:(CGLContextObj)context{
	self = [super init];
	_context = context;
	return self;
}

- (void)dealloc{
    if( _context ){
		CGLReleaseContext(_context);
	}
    [super dealloc];
}

+(EAGLContext*)currentContext{
	return [[[EAGLContext alloc] init] autorelease];
}

+(void)setCurrentContext:(EAGLContext *)context{
	if( context && context->_context ){
		CGLSetCurrentContext(context->_context);
	}else{
		CGLSetCurrentContext(NULL);
	}
}

-(EAGLContext*)makeShareContext{
	CGLPixelFormatObj fmt = CGLGetPixelFormat(_context);
	CGLContextObj shareContext = NULL;
	CGLCreateContext(fmt, _context, &shareContext);
	return [[[EAGLContext alloc] initWithContext:shareContext] autorelease];
}

@end

#endif


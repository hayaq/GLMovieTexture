//
//  GLMovieTexture.m
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//
#import "GLMovieTexture.h"
#import "MovieDecoder.h"
#import "GLImageShader.h"
#import "GLFBOTexture.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>

//#define DECODE_FORMAT '420f'
#define DECODE_FORMAT '420v'
//#define DECODE_FORMAT 'BGRA'

#define USE_GL_TEXTURE_CACHE (1)

// (iPhone5)
// '420v' '420f' : 3.8msec
// '420v' '420f' : 2.5msec (TextureCache)
// 'BGRA' : 4.0msec
// (iPod touch 4G)
// '420v' : 12msec
// '420f' : 70msec!!!
// 'BGRA' : 18msec

typedef struct{
	uint32_t textureId;
	uint32_t format;
	void    *data;
}GLTextureInfo;

@interface GLMovieTexture () <MovieDecoderDelegate>{
	uint32_t       _targetTextureId;
	uint32_t       _texNum;
	GLTextureInfo  _textures[2];
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
	////////////////////////////
	CVOpenGLESTextureCacheRef _textureCache;
	CVOpenGLESTextureRef _textureRef[2];
}
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
	if( _textureCache ){
		for (int i=0;i<_texNum;i++){
			if( _textureRef[i] ){
				CFRelease(_textureRef[i]);
			}
		}
		CVOpenGLESTextureCacheFlush(_textureCache,0);
		CFRelease(_textureCache);
	}
	
	[_fboTexture release];
	[_imageShader release];
	[_decoder release];
	[_context release];
	[super dealloc];
}

-(uint32_t)textureId{
	return _fboTexture.textureId;
}

-(void)setMovie:(NSString*)path{
	_initFlag = NO;
	[_fboTexture release];
	_fboTexture = nil;
	[_decoder release];
	_decoder = [[MovieDecoder movieDecoderWithMovie:path format:_format] retain];
	_width = 0;
	_height = 0;
}

-(void)setGLContext:(EAGLContext*)context{
	_initFlag = NO;
	_mainContext = [context retain];
	[_imageShader release];
	_imageShader = nil;
	[_fboTexture release];
	_fboTexture = nil;
	[_context release];
	[EAGLContext setCurrentContext:context];
	
	uint32_t currentTextureId = 0;
	glGetIntegerv(GL_TEXTURE_BINDING_2D,(int*)&currentTextureId);
	
	if( _format == 'BGRA' ){
		_texNum = 1;
		_textures[0].textureId = [self createTexture];
		_textures[0].format = GL_RGBA;
		_textures[1].textureId = 0;
		_imageShader = [[GLBGRAShader alloc] init];
	}else{
		_texNum = 2;
		_textures[0].textureId = [self createTexture];
		_textures[0].format = GL_LUMINANCE;
		_textures[1].textureId = [self createTexture];
		_textures[1].format = GL_LUMINANCE_ALPHA;
		_imageShader = [[GLYUVShader alloc] init];
	}
	
	if( _textureCache ){
		CFRelease(_textureCache);
		_textureCache = NULL;
	}
	
	_context = [[EAGLContext alloc] initWithAPI:context.API sharegroup:context.sharegroup];
	
	if( CVOpenGLESTextureCacheCreate && USE_GL_TEXTURE_CACHE ){
		CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,NULL, _context, NULL, &_textureCache);
	}
	
	glBindTexture(GL_TEXTURE_2D, currentTextureId);
}

-(void)setTextureId:(uint32_t)textureId{
	_initFlag = NO;
	_targetTextureId = textureId;
	if( textureId ){
		uint32_t currentTextureId = 0;
		glGetIntegerv(GL_TEXTURE_BINDING_2D,(int*)&currentTextureId);
		glBindTexture(GL_TEXTURE_2D, textureId);
		uint8_t data[16];
		memset(data, 0, 16);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 4, 4, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
		glBindTexture(GL_TEXTURE_2D,currentTextureId);
	}
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
	[EAGLContext setCurrentContext:_context];
	if( _textureCache ){
		[self pixelTransferWithTextureCache:pixBuff];
	}else{
		[self pixelTransferDefault:pixBuff];
	}
	//glFlush();
	[EAGLContext setCurrentContext:_mainContext];
}

-(void)movieDecoderDidFinishDecoding:(MovieDecoder *)decoder{
	
}

-(void)pixelTransferWithTextureCache:(CVPixelBufferRef)pixBuff
{
	BOOL firstFrame = NO;
	if( !_initFlag ){
		_initFlag = YES;
		firstFrame = YES;
		if( _format == 'BGRA' ){
			_width = CVPixelBufferGetBytesPerRow(pixBuff)/4;
			_height = CVPixelBufferGetHeight(pixBuff);
			_displayWidth = CVPixelBufferGetWidth(pixBuff);
		}else{
			_width = CVPixelBufferGetBytesPerRowOfPlane(pixBuff,0);
			_height = CVPixelBufferGetHeightOfPlane(pixBuff,0);
			_displayWidth = CVPixelBufferGetWidthOfPlane(pixBuff,0);
		}
		if( _targetTextureId ){
			_fboTexture = [[GLFBOTexture alloc] initWithTextureId:_targetTextureId size:CGSizeMake(_displayWidth,_height)];
		}else{
			_fboTexture = [[GLFBOTexture alloc] initWithSize:CGSizeMake(_displayWidth,_height)];
		}
	}
	for (int i=0;i<_texNum;i++){
		if( _textureRef[i] ){
			CFRelease(_textureRef[i]);
			_textureRef[i] = NULL;
		}
	}
	CVOpenGLESTextureCacheFlush(_textureCache,0);
	
	uint32_t textureIds[2];
	for (int i=0;i<_texNum;i++){
		glActiveTexture(GL_TEXTURE0+i);
		CVReturn ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,_textureCache,pixBuff,NULL,GL_TEXTURE_2D,_textures[i].format,
																	_width>>i,_height>>i,_textures[i].format,GL_UNSIGNED_BYTE,i,&_textureRef[i]);
		if( ret != kCVReturnSuccess ){
			if( firstFrame ){
				CFRelease(_textureCache);
				_textureCache = NULL;
				_initFlag = YES;
				[_fboTexture release];
				[self pixelTransferDefault:pixBuff];
			}
			return;
		}
		textureIds[i] = CVOpenGLESTextureGetName(_textureRef[i]);
		glBindTexture(GL_TEXTURE_2D,textureIds[i]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
	}
	float wr = (float)_width/_displayWidth;
	[_fboTexture bind];
	[_imageShader renderWithTexture:textureIds num:_texNum size:CGSizeMake(wr,1)];
	[_fboTexture unbind];
}

-(void)pixelTransferDefault:(CVPixelBufferRef)pixBuff
{
	CVPixelBufferLockBaseAddress(pixBuff, 0);
	
	for(int i=GL_TEXTURE0;i<GL_ACTIVE_TEXTURE;i++){
		glActiveTexture(i);
		glBindTexture(GL_TEXTURE_2D,0);
	}
	
	if( _format == 'BGRA' ){
		_textures[0].data = CVPixelBufferGetBaseAddress(pixBuff);
	}else{
		_textures[0].data = CVPixelBufferGetBaseAddressOfPlane(pixBuff,0);
		_textures[1].data = CVPixelBufferGetBaseAddressOfPlane(pixBuff,1);
	}
	
	if( !_initFlag ){
		_initFlag = YES;
		if( _format == 'BGRA' ){
			_width = CVPixelBufferGetBytesPerRow(pixBuff)/4;
			_height = CVPixelBufferGetHeight(pixBuff);
			_displayWidth = CVPixelBufferGetWidth(pixBuff);
		}else{
			_width = CVPixelBufferGetBytesPerRowOfPlane(pixBuff,0);
			_height = CVPixelBufferGetHeightOfPlane(pixBuff,0);
			_displayWidth = CVPixelBufferGetWidthOfPlane(pixBuff,0);
		}
		for (int i=0;i<_texNum;i++){
			glBindTexture(GL_TEXTURE_2D, _textures[i].textureId);
			glTexImage2D(GL_TEXTURE_2D, 0, _textures[i].format, _width>>i, _height>>i, 0,
						 _textures[i].format, GL_UNSIGNED_BYTE, _textures[i].data);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
		}		
		if( _targetTextureId ){
			_fboTexture = [[GLFBOTexture alloc] initWithTextureId:_targetTextureId size:CGSizeMake(_displayWidth,_height)];
		}else{
			_fboTexture = [[GLFBOTexture alloc] initWithSize:CGSizeMake(_displayWidth,_height)];
		}
	}else{
		for (int i=0;i<_texNum;i++){
			glBindTexture(GL_TEXTURE_2D, _textures[i].textureId);
			glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, _width>>i, _height>>i, _textures[i].format, GL_UNSIGNED_BYTE, _textures[i].data);
		}
	}
	
	uint32_t textureIds[2] = {_textures[0].textureId,_textures[1].textureId};
	float wr = (float)_width/_displayWidth;
	[_fboTexture bind];
	[_imageShader renderWithTexture:textureIds num:_texNum size:CGSizeMake(wr,1)];
	[_fboTexture unbind];
	glBindTexture(GL_TEXTURE_2D, 0);
	CVPixelBufferUnlockBaseAddress(pixBuff, 0);
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



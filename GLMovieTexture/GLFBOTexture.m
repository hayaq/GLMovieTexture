#import "GLFBOTexture.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GLFBOTexture(){
	uint32_t _fboId;
	uint32_t _textureId;
	int      _width;
	int      _height;
	uint32_t _selfAllocatedTextureId;
}
@end

@implementation GLFBOTexture

@synthesize fboId = _fboId;
@synthesize textureId = _textureId;

-(id)initWithTextureId:(uint32_t)textureId size:(CGSize)size{
	self = [super init];
	_textureId = textureId;
	_width = (int)size.width;
	_height = (int)size.height;
	glGenFramebuffers(1, &_fboId);
    glBindFramebuffer(GL_FRAMEBUFFER,_fboId);
	glBindTexture(GL_TEXTURE_2D, _textureId);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, _width, _height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureId, 0);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
	_selfAllocatedTextureId = 0;
	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if( status!=GL_FRAMEBUFFER_COMPLETE ){
		NSLog(@"Failed to create framebuffer object (%d)",status);
		[self release];
		return nil;
	}
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	return self;
}

-(id)initWithSize:(CGSize)size{
	self = [super init];
	_width = (int)size.width;
	_height = (int)size.height;
	glGenFramebuffers(1, &_fboId);
    glBindFramebuffer(GL_FRAMEBUFFER,_fboId);
    glGenTextures(1, &_textureId);
	glBindTexture(GL_TEXTURE_2D, _textureId);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, _width, _height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureId, 0);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
	_selfAllocatedTextureId =  _textureId;
	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if( status!=GL_FRAMEBUFFER_COMPLETE ){
		NSLog(@"Failed to create framebuffer object (%d)",status);
		[self release];
		return nil;
	}
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	return self;
}

- (void)dealloc{
	if( _fboId ){
		glDeleteFramebuffers(1, &_fboId);
	}
	if( _selfAllocatedTextureId ){
		glDeleteTextures(1,&_selfAllocatedTextureId);
	}
    [super dealloc];
}

-(void)bind{
	glBindFramebuffer(GL_FRAMEBUFFER, _fboId);
    glViewport(0, 0, _width, _height);
    glClearColor(1.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}

-(void)unbind{
	glBindFramebuffer(GL_FRAMEBUFFER,0);
}

@end

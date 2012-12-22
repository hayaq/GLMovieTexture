//
//  GLView.m
//  YUVCapture
//
//  Created by hayashi on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GLES2View.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GLES2View(){
	EAGLContext *context;
	unsigned int frameBuffer;
	unsigned int renderBuffer;
	unsigned int depthRenderbuffer;
	int width;
	int height;
}
@end

@implementation GLES2View

@synthesize width = width;
@synthesize height = height;

+ (Class) layerClass {
	return [CAEAGLLayer class];
}

- (id)init{
	self = [super init];
	[self initGLContext];
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	[self initGLContext];
    return self;
}

-(void)initGLContext{
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 ];
	[EAGLContext setCurrentContext:context];
	CAEAGLLayer *layer = (CAEAGLLayer*)self.layer;
	layer.contentsScale = [UIScreen mainScreen].scale;
}

-(void)layoutSubviews{
	[super layoutSubviews];
	[self releaseFrameBuffers];
	
	glGenFramebuffers(1, &frameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	glGenRenderbuffers(1, &renderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER,GL_RENDERBUFFER_WIDTH,&width);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER,GL_RENDERBUFFER_HEIGHT,&height);
	
	glGenRenderbuffers(1, &depthRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER, depthRenderbuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
	
	NSLog(@"GLES2: %dx%d",width,height);
}

-(void)releaseFrameBuffers{
	if( frameBuffer ){
		glDeleteFramebuffers(1,&frameBuffer);
		frameBuffer = 0;
	}
	if( renderBuffer ){
		glDeleteRenderbuffers(1,&renderBuffer);
		renderBuffer = 0;
	}
	if( depthRenderbuffer ){
		glDeleteRenderbuffers(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

-(EAGLContext*)glContext{
	return context;
}

-(EAGLContext*)createShareContext{
	return [[EAGLContext alloc] initWithAPI:context.API sharegroup:context.sharegroup];
}

-(uint32_t)createTexture{
	GLuint textureId = 0;
	glGenTextures(1,&textureId);
	glBindTexture(GL_TEXTURE_2D,textureId);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glBindTexture(GL_TEXTURE_2D,0);
	return textureId;
}

-(uint32_t)createTextureWithSize:(CGSize)size format:(int)fmt{
	int w = (int)size.width;
	int h = (int)size.height;
	GLuint format = GL_LUMINANCE;
	if( fmt == 2 ){ format = GL_LUMINANCE_ALPHA; }
	else if( fmt == 3 ){ format = GL_RGB; }
	else if( fmt == 4 ){ format = GL_RGBA; }
	GLuint textureId = 0;
	glGenTextures(1,&textureId);
	glBindTexture(GL_TEXTURE_2D,textureId);
	glTexImage2D(GL_TEXTURE_2D,0,format,w, h, 0, format,GL_UNSIGNED_BYTE,NULL);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glBindTexture(GL_TEXTURE_2D,0);
	return textureId;
}

-(void)beginRendering
{
	[EAGLContext setCurrentContext:context];
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	glViewport(0,0,width,height);
	glClearDepthf(1.f);
	glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}

-(void)endRendering
{
	glFlush();
	glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc {
    [super dealloc];
}


@end

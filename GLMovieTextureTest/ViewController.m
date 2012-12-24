//
//  ViewController.m
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import "ViewController.h"
#import "GLMovieTexture.h"
#import "GLES2View.h"
#import "GLShader.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ViewController (){
	GLES2View      *glView;
	GLMovieTexture *movieTexture;
	GLTexShader    *shader;
}
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	
	glView = [[GLES2View alloc] init];
	[self.view addSubview:glView];
	[glView release];
	
	shader = [[GLTexShader alloc] init];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"mov"];
	movieTexture = [[GLMovieTexture alloc] initWithMovie:path context:glView.glContext];
	[movieTexture play];
	
	CADisplayLink *displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(displayCallback:)];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[glView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

-(void)displayCallback:(CADisplayLink*)displayLink{
	[glView beginRendering];
	
	[self adjustViewport];
	
	const float v[8] = { -1, -1, +1, -1, +1, +1, -1, +1 };
	const float t[8] = {  0,  1,  1,  1,  1,  0,  0,  0 };
		
	[shader bind];
	[shader setTexture:movieTexture.textureId atIndex:0];
	[shader setTexture:movieTexture.subTextureId atIndex:1];
	glEnableVertexAttribArray(shader.position);
	glEnableVertexAttribArray(shader.texcoord);
	glVertexAttribPointer(shader.position, 2, GL_FLOAT, 0, 0, v);
	glVertexAttribPointer(shader.texcoord, 2, GL_FLOAT, 0, 0, t);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	glDisableVertexAttribArray(shader.position);
	glDisableVertexAttribArray(shader.texcoord);
	[shader unbind];
	
	[glView endRendering];
}

-(void)adjustViewport{
	int mw = movieTexture.width;
	int mh = movieTexture.height;
	int gw = glView.width;
	int gh = glView.height;
	int vw = gw;
	int vh = gw*mh/mw;
	if( vh > gh ){
		vh = gh;
		vw = gh*mw/mh;
	}
	glViewport((gw-vw)/2, (gh-vh)/2, vw, vh);
	
}

@end

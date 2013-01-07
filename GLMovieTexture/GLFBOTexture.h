//
//  GLFBOTexture.h
//  GLMovieTexture
//
//  Created by hayashi on 12/23/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface GLFBOTexture : NSObject{
	uint32_t _fboId;
	uint32_t _textureId;
	int      _width;
	int      _height;
	uint32_t _selfAllocatedTextureId;
}
@property (readonly) uint32_t fboId;
@property (readonly) uint32_t textureId;
-(id)initWithTextureId:(uint32_t)textureId size:(CGSize)size;
-(id)initWithSize:(CGSize)size;
-(void)bind;
-(void)unbind;
@end

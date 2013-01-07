//
//  GLYUVRender.h
//  GLMovieTexture
//
//  Created by hayashi on 12/23/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface GLImageShader : NSObject{
	uint32_t _programId;
	int      _position;
	int      _texcoord;
	int      _scale;
	int      _texNum;
	int      _textures[16];
}
-(void)renderWithTexture:(uint32_t)textureIds;
-(void)renderWithTexture:(uint32_t*)textureIds num:(int)num size:(CGSize)size;
@end

@interface GLYUVShader : GLImageShader
@end

@interface GLBGRAShader : GLImageShader
@end

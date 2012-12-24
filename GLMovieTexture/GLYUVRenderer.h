//
//  GLYUVRender.h
//  GLMovieTexture
//
//  Created by hayashi on 12/23/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLYUVRenderer : NSObject
-(void)renderWithTexture:(uint32_t)textureId uvTexture:(uint32_t)uvTextureId;
@end

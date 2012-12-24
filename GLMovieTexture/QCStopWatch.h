//
//  QCStopWatch.h
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCStopWatch : NSObject
+(id)stopWatchWithSampleCount:(int)sampleCount;
-(void)start;
-(void)stop;
@end

//
//  QCStopWatch.h
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCStopWatch : NSObject{
	uint64_t _time0;
	uint64_t _sumt;
	int _count;
	int _sampleCount;
}
+(id)stopWatchWithSampleCount:(int)sampleCount;
-(void)start;
-(void)stop;
@end

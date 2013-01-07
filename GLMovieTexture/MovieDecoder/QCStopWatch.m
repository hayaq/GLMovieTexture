//
//  QCStopWatch.m
//  GLMovieTexture
//
//  Created by hayashi on 12/22/12.
//  Copyright (c) 2012 hayashi. All rights reserved.
//

#import "QCStopWatch.h"
#import <sys/time.h>

static inline uint64_t QCGetCurrentTime();

@implementation QCStopWatch

+(id)stopWatchWithSampleCount:(int)sampleCount{
	return [[[QCStopWatch alloc] initWithSampleCount:sampleCount] autorelease];
}

-(id)init{
	self = [super init];
	_sampleCount = 100;
	return self;
}

-(id)initWithSampleCount:(int)sampleCount{
	self = [super init];
	_sampleCount = 100;
	if( sampleCount > 0 ){
		_sampleCount = sampleCount;
	}
	return self;
}

-(void)start{
	_time0 = QCGetCurrentTime();
}

-(void)stop{
	_sumt += QCGetCurrentTime()-_time0;
	if( ++_count > _sampleCount ){
		double ave = (double)_sumt/(_count*1000);
		NSLog(@"%.3f msec",ave);
		_count = 0;
		_sumt = 0;
	}
}

@end

static inline uint64_t QCGetCurrentTime(){
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return ((uint64_t)tv.tv_usec+(uint64_t)tv.tv_sec*1000000);
}


#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "QCStopWatch.h"

@protocol MovieDecoderDelegate;

@interface MovieDecoder(){
@public
	int       _width;
	int       _height;
	int       _displayWidth;
	int       _frameRate;
	int       _format;
	double    _currentTime;
	BOOL      _loop;
	////////////////////////
	BOOL      _initFlag;
	BOOL      _resetFlag;
	BOOL      _finishFlag;
	NSTimer  *_timer;
	NSRecursiveLock *_lock;
	QCStopWatch *_stopWatch;
	////////////////////////
	id<MovieDecoderDelegate> _delegate;
}
@end

// iOS4, iOS5
@interface AVAssetMovieDecoder : MovieDecoder
@end

// For iOS6 or later
@interface AVPlayerMovieDecoder : MovieDecoder
+(BOOL)isAvailable;
@end

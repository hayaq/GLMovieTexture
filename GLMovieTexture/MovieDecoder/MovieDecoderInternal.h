#import <AVFoundation/AVFoundation.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#define MOVIE_DECODER_TARGET_IOS 1
#import <AssetsLibrary/AssetsLibrary.h>
#else
#define MOVIE_DECODER_TARGET_OSX 1
#endif
#import "QCStopWatch.h"

typedef struct MovieDecoderData{
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
}MovieDecoderData;

@class AVAsset;
@class AVAssetReader;
@class AVAssetReaderTrackOutput;

// iOS4, iOS5, OSX
@interface AVAssetMovieDecoder : MovieDecoder{
	AVAsset    *_asset;
	AVAssetReader *_assetReader;
	AVAssetReaderTrackOutput *_assetReaderOutput;
}
+(BOOL)isAvailable;
@end

@class AVPlayer;
@class AVPlayerItemVideoOutput;

// For iOS6 or later
@interface AVPlayerMovieDecoder : MovieDecoder{
	AVPlayer *_player;
	AVPlayerItemVideoOutput *_output;
}
+(BOOL)isAvailable;
@end

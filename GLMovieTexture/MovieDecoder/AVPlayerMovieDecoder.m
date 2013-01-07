#import "MovieDecoder.h"
#import "MovieDecoderInternal.h"
#import <AVFoundation/AVPlayerItemOutput.h>

@implementation AVPlayerMovieDecoder

+(BOOL)isAvailable{
	if( [AVPlayerItemOutput class] ){
		return YES;
	}
	return NO;
}

-(BOOL)loadMovie:(NSString*)path
{
	[_data->_lock lock];
	NSURL *url = nil;
	if( [path hasPrefix:@"http://"] || [path hasPrefix:@"https://"] ){
		url = [NSURL URLWithString:path];
	}else if( [[NSFileManager defaultManager] fileExistsAtPath:path] ){
		url = [NSURL fileURLWithPath:path];
	}else{
		return FALSE;
	}
	AVPlayerItem* item = [AVPlayerItem playerItemWithURL:url];
	_player = [[AVPlayer playerWithPlayerItem:item] retain];
	
	_player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidFinishDecoding:)
												 name:AVPlayerItemDidPlayToEndTimeNotification object:item];
	[_data->_lock unlock];
	return TRUE;
}

-(void)dealloc{
	[_data->_lock lock];
	[_output release];
	[_player release];
	[_data->_lock unlock];
	[super dealloc];
}

-(void)setCurrentTime:(double)currentTime{
	const CMTime seekTime = CMTimeMakeWithSeconds(currentTime, 3000000);
	[_player seekToTime:seekTime completionHandler:^(BOOL finished){
		[self decodeFrame:seekTime];
		[self decodeFrame:seekTime];
	}];
}

-(void)initReader{
	[self releaseReader];
	NSDictionary *setting = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_data->_format]
														forKey:(id)@"PixelFormatType"];	
	_output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:setting];
	[_player.currentItem addOutput:_output];
}

-(void)releaseReader{
	if( _output ){
		[[_player currentItem] removeOutput:_output];
		_output = nil;
	}
	[_player seekToTime:kCMTimeZero];
}

-(void)preprocessForDecoding{
	if( _output ){
		[_player play];
		return;
	}
	[self initReader];
	[_player play];
}

-(void)postprocessForDecoding{
	[_player pause];
	[self releaseReader];
}

-(void)processForPausing{
	[_player pause];
}

-(void)processForDecoding
{
	float duration = CMTimeGetSeconds(_player.currentItem.duration);
	if( _player.status != AVPlayerStatusReadyToPlay ) {
		return;
	}
	if( duration <= 0 || isnan(duration) ){
		return;
	}
	if( _data->_initFlag ){
		if( [self bufferedTime] < (duration*0.9f) ){
			if( _player.rate > 0.f ){
				[_player pause];
			}
			return;
		}
	}
	if( _player.rate == 0.f ){
		if( _player.currentItem.isPlaybackLikelyToKeepUp ){
			[_player play];
		}
	}
	[self decodeFrame:_player.currentItem.currentTime];
}

-(void)decodeFrame:(CMTime)tm{
	CVPixelBufferRef pixBuff = [_output copyPixelBufferForItemTime:tm itemTimeForDisplay:NULL];
	if( !pixBuff ){ return; }
	_data->_currentTime = CMTimeGetSeconds(tm);
	[_data->_delegate movieDecoderDidDecodeFrame:self pixelBuffer:pixBuff];
	CVPixelBufferRelease(pixBuff);
}

-(void)movieDidFinishDecoding:(NSNotification*)nf{
	[_data->_delegate movieDecoderDidFinishDecoding:self];
	if( _data->_loop ){
		[_player seekToTime:kCMTimeZero];
		[_player play];
	}else{
		[self stop];
	}
}

-(BOOL)isFinished{
	AVPlayerItem *item = _player.currentItem;
	return (CMTimeCompare(item.currentTime,item.duration)==0)? YES : NO;
}

-(float)bufferedTime{
	float bt = 0;
	for( NSValue *r in [_player.currentItem loadedTimeRanges] ){
		CMTimeRange range = [r CMTimeRangeValue];
		float tv =  CMTimeGetSeconds(CMTimeRangeGetEnd(range));
		if( tv > bt ){
			bt = tv;
		}
	}
	return bt;
}

@end

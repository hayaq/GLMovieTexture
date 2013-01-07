#import "MovieDecoder.h"
#import "MovieDecoderInternal.h"

@implementation AVAssetMovieDecoder

+(BOOL)isAvailable{
	return YES;
}

-(BOOL)loadMovie:(NSString*)path
{
	[_data->_lock lock];
	if( _assetReader ){
		[_data->_lock unlock];
		return FALSE;
	}
	[_asset release];
	_asset = nil;
	if( [path hasPrefix:@"http://"] || [path hasPrefix:@"https://"] ){
		NSLog(@"AVAssetMovieDecoder does not support non-local movie decoding!");
		return FALSE;
	}else{
		_asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
	}
	[_data->_lock unlock];
	return TRUE;
}

-(void)dealloc{
	[_data->_lock lock];
	[_asset release];
	[_assetReader release];
	[_assetReaderOutput release];
	[_data->_lock unlock];
	[super dealloc];
}

-(void)initReader{
	[self releaseReader];
	AVAssetTrack *track = [[_asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	NSDictionary *setting = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_data->_format]
														forKey:(id)@"PixelFormatType"];	
	_assetReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:setting];
	
	// important for decoding perfomance!!! (>=iOS5.0)
	if( [_assetReaderOutput respondsToSelector:@selector(alwaysCopiesSampleData)] ){
		_assetReaderOutput.alwaysCopiesSampleData = NO;
	}
	_assetReader = [[AVAssetReader alloc] initWithAsset:_asset error:nil];
	[_assetReader addOutput:_assetReaderOutput];
	CMTime tm = CMTimeMake((int64_t)(_data->_currentTime*30000), 30000);
	[_assetReader setTimeRange:CMTimeRangeMake(tm,_asset.duration)];
	[_assetReader startReading];
}

-(void)releaseReader{
	[_assetReader release];
	_assetReader = nil;
	[_assetReaderOutput release];
	_assetReaderOutput = nil;
}

-(void)preprocessForDecoding{
	[self initReader];
}

-(void)postprocessForDecoding{
	[self releaseReader];
}

-(void)processForDecoding
{
	if( _assetReader.status != AVAssetReaderStatusReading ){
		if( _assetReader.status == AVAssetReaderStatusCompleted ){
			if( !_data->_loop ){
				[_data->_timer invalidate];
				_data->_timer = nil;
				_data->_resetFlag = YES;
				[_data->_delegate movieDecoderDidFinishDecoding:self];
				_data->_currentTime = 0;
				[self releaseReader];
				return;
			}else{
				[_data->_delegate movieDecoderDidFinishDecoding:self];
				_data->_currentTime = 0;
				[self initReader];
			}
		}
	}
	CMSampleBufferRef sampleBuffer = [_assetReaderOutput copyNextSampleBuffer];
	if( !sampleBuffer ){ return; }
	_data->_currentTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
	CVPixelBufferRef pixBuff = CMSampleBufferGetImageBuffer(sampleBuffer);
	[_data->_delegate movieDecoderDidDecodeFrame:self pixelBuffer:pixBuff];
	CVPixelBufferRelease(pixBuff);
	CMSampleBufferInvalidate(sampleBuffer);
}

-(BOOL)isFinished{
	return (_assetReader.status==AVAssetReaderStatusCompleted)? YES : NO;
}

@end


#import "MovieDecoder.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "QCStopWatch.h"

@interface MovieDecoder (){
	int       width;
	int       height;
	int       frameRate;
	int       format;
	NSTimer  *timer;
	double    currentTime;
	int       currentFrame;
	BOOL      initFlag;
	BOOL      resetFlag;
	void     *buffers[2];
	AVURLAsset    *asset;
	AVAssetReader *assetReader;
	AVAssetReaderTrackOutput *assetReaderOutput;
	id<MovieDecoderDelegate> delegate;
	QCStopWatch *stopWatch;
}
@end


@implementation MovieDecoder

@synthesize delegate;
@synthesize frameRate;
@synthesize width, height;
@synthesize currentFrame;
@synthesize currentTime;

-(id)init{
	self = [super init];
	width = 0;
	height = 0;
	frameRate = 30;
	currentTime = 0;
	currentFrame = 0;
	format = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
	stopWatch = [[QCStopWatch stopWatchWithSampleCount:100] retain];
	return self;
}

-(id)initWithMovie:(NSString*)path format:(int)fmt
{
	self = [self init];
	format = fmt;
	[self loadMovie:path];
	return self;
}

-(BOOL)loadMovie:(NSString*)path
{
	NSURL *url = [NSURL fileURLWithPath:path];
	if( asset ){
		[asset release];
	}
	asset = [[AVURLAsset alloc] initWithURL:url options:nil];
	AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	width = (int)track.naturalSize.width;
	height = (int)track.naturalSize.height;
	return TRUE;
}

-(void)dealloc
{
	[stopWatch release];
	[asset release];
	[assetReader release];
	[assetReaderOutput release];
	[super dealloc];
}

-(void)captureLoop
{
	// Decode performance on iPhone5
	// '420f' : default=6.3msec nocopy=3.1msec
	// '420v' : default=6.3msec nocopy=3.1msec
	// 'BGRA' : default=9.0msec nocopy=5.3msec
	
	if( assetReader.status != AVAssetReaderStatusReading ){
		if( assetReader.status == AVAssetReaderStatusCompleted ){
			[timer invalidate];
			timer = nil;
			resetFlag = YES;
			if( [delegate respondsToSelector:@selector(movieDecoderDecodeFinished:)]){
				[delegate movieDecoderDecodeFinished:self];
			}
		}
		return;
	}
	
	[stopWatch start];
	CMSampleBufferRef sampleBuffer = [assetReaderOutput copyNextSampleBuffer];
	if( !sampleBuffer ){ return; }
	
	CVImageBufferRef pixBuff = CMSampleBufferGetImageBuffer(sampleBuffer); 
	CVPixelBufferLockBaseAddress(pixBuff,0);
	
	currentTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
		
	if( format == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange || 
	   format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange ){
		buffers[0] = CVPixelBufferGetBaseAddressOfPlane(pixBuff,0);
		buffers[1] = CVPixelBufferGetBaseAddressOfPlane(pixBuff,1);
		if( !initFlag ){
			width  = CVPixelBufferGetWidthOfPlane(pixBuff,0);
			height = CVPixelBufferGetHeightOfPlane(pixBuff,0);
			initFlag = YES;
			NSLog(@"MovieDecoder %dx%dx (YUV)",width,height);
		}
	}else if( format == kCVPixelFormatType_32BGRA ){
		buffers[0] = CVPixelBufferGetBaseAddress(pixBuff);
		buffers[1] = NULL;
		if( !initFlag ){
			width  = CVPixelBufferGetWidth(pixBuff);
			height = CVPixelBufferGetHeight(pixBuff);
			initFlag = YES;
			NSLog(@"MovieDecoder %dx%dx (BGRA)",width,height);
		}
	}else{
		buffers[0] = NULL;
		buffers[1] = NULL;
	}
	[delegate movieDecoderDecodeFrame:self buffers:buffers];
	CVPixelBufferUnlockBaseAddress(pixBuff,0);
	CVPixelBufferRelease(pixBuff);
	CMSampleBufferInvalidate(sampleBuffer);
	
	[stopWatch stop];
	
	currentFrame++;
}

-(void)initAssetReader{
	AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	NSDictionary *setting = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:format]
														forKey:(id)@"PixelFormatType"];	
	assetReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:setting];
	
	// important for decoding perfomance!!! (>=iOS5.0)
	if( [assetReaderOutput respondsToSelector:@selector(alwaysCopiesSampleData)] ){
		assetReaderOutput.alwaysCopiesSampleData = NO;
	}
	assetReader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
	[assetReader addOutput:assetReaderOutput];
	[assetReader startReading];
}

-(void)start{
	if( [self isRunning] ){
		return;
	}
	initFlag = NO;
	if( resetFlag ){
		[self stop];
		resetFlag = NO;
	}
	if( !assetReader ){
		[self initAssetReader];
	}
	if( !timer ){
		timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/frameRate)
												 target:self
											   selector:@selector(captureLoop)
											   userInfo:nil repeats:YES];
	}else{
		[timer fire];
	}
}

-(void)pause{
	if( ![self isRunning] ){
		return;
	}
	[timer invalidate];
	timer = nil;	
}

-(void)stop{
	currentTime  = 0;
	currentFrame = 0;
	[timer invalidate];
	[assetReaderOutput release];
	[assetReader release];
	timer = nil;
	assetReaderOutput = nil;
	assetReader = nil;
}

-(void)captureNext
{
	if( !assetReader ){
		[self initAssetReader];
	}
	[self captureLoop];
}

-(BOOL)isFinished
{
	if( assetReader && assetReader.status == AVAssetReaderStatusCompleted ){
		return YES;
	}
	return NO;
}

-(BOOL)isRunning
{
	if( timer && [timer isValid] ){
		return YES;
	}
	return NO;
}



@end

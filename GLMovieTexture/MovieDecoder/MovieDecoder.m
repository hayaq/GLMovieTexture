#import "MovieDecoder.h"
#import "MovieDecoderInternal.h"

@implementation MovieDecoder

@synthesize width = _width;
@synthesize height = _height;
@synthesize format = _format;
@synthesize displayWidth = _displayWidth;
@synthesize frameRate = _frameRate;
@synthesize currentTime = _currentTime;
@synthesize loop = _loop;
@synthesize delegate = _delegate;

-(id)init{
	self = [super init];
	[self init_];
	return self;
}

-(id)initWithMovie:(NSString*)path format:(int)format
{
	self = [super init];
	[self init_];
	_format = format;
	[self loadMovie:path];
	return self;
}

-(void)init_{
	_lock = [[NSRecursiveLock alloc] init];
	_stopWatch = [[QCStopWatch stopWatchWithSampleCount:100] retain];
	_format = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
	_frameRate = 30;
}

- (void)dealloc
{
	[_lock lock];
	[_timer invalidate];
	[_stopWatch release];
	[_lock unlock];
	[_lock release];
    [super dealloc];
}

-(BOOL)loadMovie:(NSString*)path{
	return FALSE;
}

-(void)start{
	[_lock lock];
	if( [self isRunning] ){
		[_lock unlock];
		return;
	}
	_initFlag = NO;
	[self preprocessForDecoding];
	_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0/_frameRate)
											  target:self
											selector:@selector(captureLoop)
											userInfo:nil repeats:YES];
	[_lock unlock];
}

-(void)pause{
	[_lock lock];
	if( ![self isRunning] ){
		[_lock unlock];
		return;
	}
	[_timer invalidate];
	_timer = nil;
	[self processForPausing];
	[_lock unlock];
}

-(void)stop{
	[_lock lock];
	_currentTime  = 0;
	[_timer invalidate];
	_timer = nil;
	[self postprocessForDecoding];
	[_lock unlock];
}

-(void)captureLoop{
	[_stopWatch start];
	[self captureNext];
	[_stopWatch stop];
	//NSLog(@"capture: %f",_currentTime);
}

-(void)captureNext{
	[_lock lock];
	[self processForDecoding];
	[_lock unlock];
}

-(BOOL)isFinished{
	return NO;
}

-(BOOL)isRunning{
	return [_timer isValid]? YES : NO;
}

-(void)preprocessForDecoding{}

-(void)postprocessForDecoding{}

-(void)processForDecoding{}

-(void)processForPausing{}

/////////////////////////////////////

+(id)movieDecoder{
	MovieDecoder *decoder = nil;
	if( [AVPlayerMovieDecoder isAvailable] ){
		decoder = [AVPlayerMovieDecoder alloc];
	}else{
		decoder = [AVAssetMovieDecoder alloc];
	}
	return [[decoder init] autorelease];
}

+(id)movieDecoderWithMovie:(NSString*)path format:(int)format{
	MovieDecoder *decoder = nil;
	if( [AVPlayerMovieDecoder isAvailable] ){
		decoder = [AVPlayerMovieDecoder alloc];
	}else{
		decoder = [AVAssetMovieDecoder alloc];
	}
	return [[decoder initWithMovie:path format:format] autorelease];
}


@end


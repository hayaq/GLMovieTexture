//
//  ARMovieDecoder.h
//  ARMoviePlayer
//
//  Created by hayashi on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class MovieDecoder;

@protocol MovieDecoderDelegate <NSObject>
@required
-(void)movieDecoderDidDecodeFrame:(MovieDecoder*)decoder pixelBuffer:(CVPixelBufferRef)buffer;
@optional
-(void)movieDecoderDidFinishDecoding:(MovieDecoder*)decoder;
@end

@interface MovieDecoder : NSObject
@property (nonatomic,readonly) int    width, height, displayWidth;
@property (nonatomic,readonly) BOOL   isRunning,isFinished;
@property (nonatomic,assign)   int    format;
@property (nonatomic,assign)   int    frameRate;
@property (nonatomic,assign)   double currentTime;
@property (nonatomic,assign)   BOOL   loop;
@property (nonatomic,assign)   id<MovieDecoderDelegate> delegate;
-(id)initWithMovie:(NSString*)path format:(int)format;
-(BOOL)loadMovie:(NSString*)path;
-(void)start;
-(void)pause;
-(void)stop;
-(void)captureNext;
+(id)movieDecoder;
+(id)movieDecoderWithMovie:(NSString*)path format:(int)format;
@end

//
//  ARMovieDecoder.h
//  ARMoviePlayer
//
//  Created by hayashi on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVURLAsset;
@class AVAssetReader;
@class AVAssetReaderTrackOutput;
@class MovieDecoder;

@protocol MovieDecoderDelegate <NSObject>
@required
-(void)movieDecoderDecodeFrame:(MovieDecoder*)decoder buffers:(void**)buffers;
@optional
-(void)movieDecoderDecodeFinished:(MovieDecoder*)decoder;
@end

@interface MovieDecoder : NSObject
@property (nonatomic,assign)   double currentTime;
@property (nonatomic,readonly) int    currentFrame;
@property (nonatomic,readonly) BOOL   isRunning,isFinished;
@property (nonatomic,readonly) int    width, height;
@property (nonatomic,assign)   int    frameRate;
@property (nonatomic,assign)   BOOL   loop;
@property (nonatomic,assign)   id<MovieDecoderDelegate> delegate;

-(id)initWithMovie:(NSString*)path format:(int)format;
-(BOOL)loadMovie:(NSString*)path;
-(void)start;
-(void)pause;
-(void)stop;
-(void)captureNext;

@end

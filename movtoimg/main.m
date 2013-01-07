//
//  main.m
//  movtopng
//
//  Created by hayashi on 1/8/13.
//  Copyright (c) 2013 hayashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <QTKit/QTKit.h>

static CGImageRef CGImageFromMovieFrameAtTime(NSString *moviePath, double t);

int main(int argc, const char * argv[])
{
	@autoreleasepool {
		
		if( argc < 2 ){
			printf("Usage movtopng <path_to_mov> [-o <path_to_png>]\n");
			return -1;
		}
		
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		
		NSString *moviePath = [NSString stringWithUTF8String:argv[1]];
		if( ![moviePath hasPrefix:@"/"] ){
			moviePath = [[[NSFileManager defaultManager] currentDirectoryPath]
						 stringByAppendingPathComponent:moviePath];
		}
		
		NSString *dstPath = nil;
		if( [ud objectForKey:@"o"] ){
			dstPath = [ud stringForKey:@"o"];
		}else{
			dstPath = [moviePath stringByAppendingPathExtension:@"jpg"];
		}
		
		double extractTime = 0;
		if( [ud objectForKey:@"t"] ){
			extractTime = [ud doubleForKey:@"t"];
		}
		
		CGImageRef cgImage = CGImageFromMovieFrameAtTime(moviePath,extractTime);
		if( !cgImage ){
			printf("Failed to decode movie\n");
			return -1;
		}
		
		NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
		NSData *pngData = [rep representationUsingType:NSJPEGFileType properties: nil];
		[pngData writeToFile:dstPath atomically:YES];
		CGImageRelease(cgImage);
	}
    return 0;
}


static CGImageRef CGImageFromMovieFrameAtTime(NSString *moviePath, double t)
{
	NSError *error = nil;
	QTMovie *movie = [QTMovie movieWithFile:moviePath error:&error];
	if( error ){
		printf("Error: %s\n",[[error description] UTF8String]);
		return NULL;
	}
	QTTime movieTime = movie.currentTime;
	if( (long long)(t*movie.duration.timeScale) > movie.duration.timeValue ){
		movieTime = movie.duration;
	}else{
		movieTime.timeValue = (long long)(t*movieTime.timeScale);
	}
	NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
						  QTMovieFrameImageTypeCGImageRef,QTMovieFrameImageType,
						  [NSNumber numberWithBool:YES],QTMovieFrameImageHighQuality,
						  nil];
	CGImageRef videoFrame = [movie frameImageAtTime:movieTime withAttributes:attr error:&error];
	if( error ){
		printf("Error: %s\n",[[error description] UTF8String]);
		return NULL;
	}
	
	return videoFrame;
}


#import <Foundation/Foundation.h>
#import "GLMovieTexture.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#define DUMP(...) { fprintf(stderr,__VA_ARGS__); fputc('\n',stderr); }
#else
#define DUMP(...) NSLog(@__VA_ARGS__)
#endif

#define GetInstance(iid) ((GLMovieTexture*)(uintptr_t)(iid))

static NSString* GetMoviePath(const char *name,const char *dataPath);

uint64_t _Load(const char *name,uint32_t textureId,const char *dataPath){
	NSString *path = GetMoviePath(name,dataPath);
	if( !path ){
		DUMP("Failed to find movie '%s'",name);
		return 0;
	}
	DUMP("Load(%s,%d)",name,textureId);
	
	EAGLContext *context = [EAGLContext currentContext];
	if( !context ){
		DUMP("No GLContext binded");
		return 0;
	}
	GLMovieTexture *instance = [[GLMovieTexture alloc] initWithMovie:path
															 context:context];
	[instance setTextureId:textureId];
	return (uint64_t)(uintptr_t)instance;
}

void _Unload(uint64_t instanceId){
	DUMP("Unload(%llx)",instanceId);
	if( instanceId==0 ){ return; }
	GLMovieTexture *instance = GetInstance(instanceId);
	[instance release];
}

void _Play(uint64_t instanceId){
	DUMP("Play(%llx)",instanceId);
	if( instanceId==0 ){ return; }
	GLMovieTexture *instance = GetInstance(instanceId);
	[instance play];
}

void _Pause(uint64_t instanceId){
	DUMP("Pause(%llx)",instanceId);
	if( instanceId==0 ){ return; }
	GLMovieTexture *instance = GetInstance(instanceId);
	[instance pause];
}

float _CurrentTime(uint64_t instanceId){
	if( instanceId==0 ){ return 0.f; }
	GLMovieTexture *instance = GetInstance(instanceId);
	return instance.currentTime;
}

void _SetCurrentTime(uint64_t instanceId,float t){
	DUMP("SetCurrentTime(%llx,%f)",instanceId,t);
	if( instanceId==0 ){ return; }
	GLMovieTexture *instance = GetInstance(instanceId);
	instance.currentTime = t;
}

uint8_t _Loop(uint64_t instanceId){
	DUMP("Loop(%llx)",instanceId);
	if( instanceId==0 ){ return 0; }
	GLMovieTexture *instance = GetInstance(instanceId);
	return (uint8_t)instance.loop;
}

void _SetLoop(uint64_t instanceId,uint8_t loop){
	DUMP("SetLoop(%llx,%d)",instanceId,loop);
	if( instanceId==0 ){ return; }
	GLMovieTexture *instance = GetInstance(instanceId);
	instance.loop = (BOOL)loop;
}

uint8_t _IsPlaying(uint64_t instanceId){
	if( instanceId==0 ){ return 0; }
	GLMovieTexture *instance = GetInstance(instanceId);
	return (uint8_t)instance.isPlaying;
}

static NSString* GetMoviePath(const char *name,const char *dataPath)
{
	NSString *moviePath = nil;
	NSString *movieName = [NSString stringWithUTF8String:name];
	if( [movieName hasPrefix:@"http://"] || [movieName hasPrefix:@"https://"] ){
		return movieName;
	}
	
	if( dataPath ){
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
		moviePath = [NSString stringWithFormat:@"%s/Raw/%s",dataPath,name];
#else
		moviePath = [NSString stringWithFormat:@"%s/StreamingAssets/%s",dataPath,name];
#endif
	}else{
		moviePath = movieName;
	}
	
	NSString *ext = [[movieName pathExtension] lowercaseString];
	if( [ext isEqual:@"mov"] || [ext isEqual:@"m4v"] || [ext isEqual:@"mp4"] ){
		if( [[NSFileManager defaultManager] fileExistsAtPath:moviePath] ){
			return moviePath;
		}
	}
	
	return nil;
}


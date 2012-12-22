#import <UIKit/UIKit.h>

@class EAGLContext;

@interface GLES2View : UIView
@property (readonly) EAGLContext *glContext;
@property (readonly) int width;
@property (readonly) int height;
-(void)beginRendering;
-(void)endRendering;
-(EAGLContext*)createShareContext;
-(uint32_t)createTexture;
-(uint32_t)createTextureWithSize:(CGSize)size format:(int)fmt;
@end

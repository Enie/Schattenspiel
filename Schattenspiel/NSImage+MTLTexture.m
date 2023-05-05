#import "NSImage+MTLTexture.h"
#import <Metal/Metal.h>

@implementation NSImage (MTLTexture)

- (id)initWithMTLTexture:(id<MTLTexture>)texture {
    int width = (int)texture.width;
    int height = (int)texture.height;
    self = [self initWithSize:NSMakeSize(width, height)];

    if (self){
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        id<MTLBuffer> byteBuffer = [device newBufferWithLength:width*height * 4 options:(0)];
        id<MTLCommandQueue> queue = [device newCommandQueue];
        id<MTLCommandBuffer> buffer = [queue commandBuffer];
        id<MTLBlitCommandEncoder> blitEncoder = [buffer blitCommandEncoder];
        
        [blitEncoder copyFromTexture:texture
                         sourceSlice:0
                         sourceLevel:0
                        sourceOrigin:(MTLOriginMake(0, 0, 0))
                          sourceSize:(MTLSizeMake(width, height, 1))
                            toBuffer:byteBuffer
                   destinationOffset:0
              destinationBytesPerRow:width * 4
            destinationBytesPerImage:width*height * 4];
        
        [blitEncoder endEncoding];
        [buffer commit];
        [buffer waitUntilCompleted];
        
        NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
                                                                           pixelsWide:width
                                                                           pixelsHigh:height
                                                                        bitsPerSample:8
                                                                      samplesPerPixel:4
                                                                             hasAlpha:YES
                                                                             isPlanar:NO
                                                                       colorSpaceName:NSCalibratedRGBColorSpace
                                                                         bitmapFormat:0
                                                                          bytesPerRow:width*4
                                                                         bitsPerPixel:32];
        
        memcpy(newRep.bitmapData, [byteBuffer contents], width*height * 4);
        
        [self addRepresentation:newRep];
    }
    return self;
}

@end

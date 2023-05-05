#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (MTLTexture)

- (id)initWithMTLTexture:(id<MTLTexture>)texture;

@end

NS_ASSUME_NONNULL_END

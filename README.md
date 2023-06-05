![App Icon](https://raw.githubusercontent.com/Enie/Schattenspiel/main/Schattenspiel/Assets.xcassets/AppIcon.appiconset/Schattenspiel%40256.png)

# Schattenspiel (very early access)

This is a shader toy for Metal Shader Library Kernels.

It is not yet capable to handle vertex or fragment shaders. Only kernels.

## Usage

When creating a new project you will see your main.mtl file. It already has a basic kernel function.

Currently only one kernel function per project is support. The name or that function is parsed by Schattenspiel. The first texture bound to the kernel is the output texture that you can see in the preview. If you add input textures, these will be bound after the output picture.

```c++
kernel void mySuperFastFilter(texture2d<float, access::write> t [[texture(0)]],
                              texture2d<float, access::read> in [[texture(1)]],
                              uint2 id [[thread_position_in_grid]]) {
  // your filter code goes here.
}
```

## Export Images

By right clicking the preview image you can export a PNG file with custom size.

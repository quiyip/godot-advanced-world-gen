# godot-advanced-world-gen
Advanced procedural 2D world generator made with Godot.

Features:
- Procedural terrain generation using `OpenSimplexNoise`.
- Adjustable generation parameters at runtime.
- Chunk-based with adjustable chunk size.
- Different biomes generated based on height.
- Uses threading to make sure generation doesn't block main thread.

![image](https://user-images.githubusercontent.com/95621115/156170764-310938d7-b6b5-4fc2-9879-59f805907ead.png)
[On my website](https://quiyip.com/godot-advanced-world-generator/) you can see a video of the world generator being used with different settings.

TODO:
- Adjustable sea level.
- Add humidity & temperature maps and map values to appropriate biomes like desert, swamp, jungle etc.
- Changing height, temperature and humidity mappings to different biomes at runtime.
- Terrain population (trees, bushes, flowers etc.)
- Structures (villages, castles, huts etc.)


package anissen.game;

import flambe.animation.Ease;
import flambe.display.ImageSprite;

class LevelLoader
{
    public static function load (ctx :GameContext, file :String) :TileMap
    {
        var tilemap = new TileMap();

        var tiledData;
        try {
            tiledData = haxe.Json.parse(ctx.pack.getFile(file).toString());
        } catch (e :Dynamic) {
            trace("[LevelLoader::load] Error loading " + file + ": " + e);
            return tilemap;
        }

        var layers :Dynamic = tiledData.layers;
        var tilesets = tiledData.tilesets;
        var tileset :Dynamic = tilesets[0]; // TODO: HACK

        tilemap.init(tiledData.width, tiledData.height);

        var tilesetImage :String = tileset.image;
        var layerTexture = ctx.pack.getTexture("tilesets/" + tilesetImage.split('.png')[0]);
        
        for (layerIndex in 0...layers.length) {
            var layer :Dynamic = layers[layerIndex];
            if (layer.type == "tilelayer") {
                for (index in 0...layer.data.length) {
                    var x = layer.x + index % layer.width;
                    var y = layer.y + Math.floor(index / layer.width);
                    var entity = tilemap.getTile(x, y);

                    var layerData :Int = layer.data[index];
                    var firstId :Int = tileset.firstgid;
                    var tileType :Int = layerData - firstId;

                    if (tileType >= 0) {
                        var tileImageX :Int = Math.floor((tileType * tileset.tilewidth) % tileset.imagewidth * tileset.tilewidth);
                        var tileImageY :Int = Math.floor((tileType * tileset.tileheight) / tileset.imageheight  * tileset.tileheight);
                        var sprite = new ImageSprite(layerTexture.subTexture(tileImageX, tileImageY, tileset.tileheight, tileset.tilewidth));
                        sprite.centerAnchor();
                        sprite.setXY(tilemap.getViewWidth() / 2, tilemap.getViewHeight() / 2);
                        sprite.x.animateTo(tilemap.tileToView(x), 1 + Math.random(), Ease.elasticOut);
                        sprite.y.animateTo(tilemap.tileToView(y), 1 + Math.random(), Ease.elasticOut);
                        sprite.scaleX.animateTo(1.0, 1 + Math.random(), Ease.elasticOut);
                        sprite.scaleY.animateTo(1.0, 1 + Math.random(), Ease.elasticOut);
                        entity.add(sprite);
                    }
                    
                    // onTileCreated.emit(entity);
                    // owner.addChild(entity);
                }
            } else if (layer.type == "objectgroup") {
                for (objectIndex in 0...layer.objects.length) {
                    var object :Dynamic = layer.objects[objectIndex];
                    trace("Object: '" + object.name + "' at " + (object.x / tileset.tilewidth) + " x " + (object.y / tileset.tileheight));
                }
            }
        }
        
        return tilemap;
    }
}

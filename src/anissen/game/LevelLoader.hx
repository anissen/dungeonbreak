
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

        var layers = tiledData.layers;
        var tilesets = tiledData.tilesets;

        var layer :Dynamic = layers[0]; // TODO: HACK
        var tileset :Dynamic = tilesets[0]; // TODO: HACK

        tilemap.init(tiledData.width, tiledData.height);

        var tilesetImage :String = tileset.image;
        var layerTexture = ctx.pack.getTexture("tilesets/" + tilesetImage.split('.png')[0]);
        
        for (index in 0...layer.data.length) {
            var x = layer.x + index % layer.width;
            var y = Math.floor(index / layer.width);
            // var entity = new Entity();
            // tilemap.setTile(entity, x, y);
            var entity = tilemap.getTile(x, y);

            var layerData :Int = layer.data[index];
            var firstId :Int = tileset.firstgid;
            var tileType :Int = layerData - firstId;
            /*
            switch (tileType) {
                case 172: entity.add(new StraightTile(_ctx, x, y, rotation = 0));
                case 170: entity.add(new StraightTile(_ctx, x, y, rotation = 1));
                case 14: entity.add(new BendTile(_ctx, x, y, rotation = 0));
                case 0: entity.add(new EmptyTile(_ctx, x, y, rotation));
                case 2: entity.add(new GoalTile(_ctx, x, y, rotation = 2));
                case 1: entity.add(new BlockTile(_ctx, x, y, 0));
                default: trace("Unkown tile type: ", type);
            }

            var tileSprite = entity.get(Sprite);
            tileSprite.centerAnchor();
            tileSprite.setXY(tilemap.getViewWidth() / 2, tilemap.getViewHeight() / 2);
            tileSprite.x.animateTo(tilemap.tileToView(x), 1 + Math.random(), Ease.elasticOut);
            tileSprite.y.animateTo(tilemap.tileToView(y), 1 + Math.random(), Ease.elasticOut);
            tileSprite.scaleX.animateTo(1.0, 1 + Math.random(), Ease.elasticOut);
            tileSprite.scaleY.animateTo(1.0, 1 + Math.random(), Ease.elasticOut);
            */

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
        return tilemap;
    }
}


package anissen.game;

import flambe.animation.Ease;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.FMath;
import flambe.script.*;
import flambe.script.CallFunction;
import flambe.script.Shake;
import flambe.sound.Sound;
import flambe.sound.Playback;
import flambe.util.Signal1;
import flambe.display.EmitterSprite;
import flambe.display.EmitterMold;
import flambe.display.EmitterSprite;
import flambe.util.Value;
import flambe.System;
import anissen.tiles.*;

/** Logic for tile map. */
class LevelMap extends Component
{
    private var _ctx :GameContext;
    private var _name :String;
    private var _file :String;
    private var _moveSpeed :Float = 200;

    private var tilemap :TileMap;

    public var playerEntity (default, null) :Entity;
    public var moves (default, null) :Value<Int>;

    public function new (ctx :GameContext, file :String, tileSize :Int, width :Int, height :Int)
    {
        _ctx = ctx;
        _file = file;
        // tilemap = new TileMap(tileSize, width, height);
        moves = new Value<Int>(0);
    }

    override public function onAdded ()
    {
        var movingTile = null;

        // var emitterMold :EmitterMold = new EmitterMold(_ctx.pack, "particles/explode");
        // var emitter :EmitterSprite = emitterMold.createEmitter();
        // var emitterEntity :Entity = new Entity().add(emitter);

        var levelLoader = new LevelLoader(_ctx);

        levelLoader.onTileCreated.connect(function(tile) {
            var tileData = tile.get(TileData);
            switch (tileData.type) {
                case -1: // Empty
                case 0: // Straight
                    tile
                        .add(new TilePath.TopOpen())
                        .add(new TilePath.BottomOpen());
                case 1: // Bottom/Right bend
                    tile
                        .add(new TilePath.BottomOpen())
                        .add(new TilePath.RightOpen());
                case 2: // Block
                default: trace('Unknown tile type: $tileData.type');
            }
        });

        var startTile :Entity = null;
        levelLoader.onObjectParsed.connect(function(name, tile) {
            switch (name) {
                case "entrance": startTile = tile;
                case "exit": tile.add(new TilePath.Goal());
                default: trace('Unknown object: $name');
            }
        });

        tilemap = levelLoader.load(_file);
        tilemap.onTileClicked.connect(function(tile) {
            var tileData = tile.get(TileData);
            var player = playerEntity.get(Player);
            if (player._tile == null) return;
            var path = getPathTo(tileData.tileX, tileData.tileY);
            player.move(path);
        });

        tilemap.onTileDragging.connect(function(tile) {
            var tileData = tile.get(TileData);
            var displacementX :Float = System.pointer.x - tilemap.tileToView(tileData.tileX);
            var displacementY :Float = System.pointer.y - tilemap.tileToView(tileData.tileY);
            // TODO: Check if row/column has a BLOCK tile
            if (Math.abs(displacementX) > Math.abs(displacementY)) {
                displaceColumn(tileData.tileX, 0);
                displaceRow(tileData.tileY, FMath.clamp(displacementX, -128, 128)); // TODO: Don't use hardcoded tile size
            } else {
                displaceRow(tileData.tileY, 0);
                displaceColumn(tileData.tileX, FMath.clamp(displacementY, -128, 128)); // TODO: Don't use hardcoded tile size
            }
        });

        tilemap.onTileDragged.connect(function(tile) {
            var tileData = tile.get(TileData);
            var displacementX :Int = tilemap.viewToTile(Math.floor(System.pointer.x - tilemap.tileToView(tileData.tileX)));
            var displacementY :Int = tilemap.viewToTile(Math.floor(System.pointer.y - tilemap.tileToView(tileData.tileY)));
            if (displacementX != 0) {
                moveRow(tileData.tileY, displacementX);
            } else if (displacementY != 0) {
                moveColumn(tileData.tileX, displacementY);
            }
        });

        for (y in 0...tilemap.getHeight()) {
            for (x in 0...tilemap.getWidth()) {
                var entity = tilemap.getTile(x, y);
                owner.addChild(entity);
            }
        }

        // Create the player's sprite
        var player = new Player(_ctx, "player/star");
        playerEntity = new Entity().add(player);
        owner.addChild(playerEntity);
        // owner.addChild(emitterEntity);

        player.onMoved.connect(function() {
            _ctx.pack.getSound("sounds/moves/move" + Math.floor(1 + Math.random() * 6)).play();
        });

        var playerSprite = playerEntity.get(Sprite);
        playerSprite.setAlpha(0.0);

        var spawnPlayerScript = new Script();
        owner.add(spawnPlayerScript);
        spawnPlayerScript.run(new Sequence([
            new Shake(2, 2, 0.5),
            new CallFunction(function() {
                var startTileSprite = startTile.get(Sprite);
                playerSprite.setXY(startTileSprite.x._, startTileSprite.y._);
                playerSprite.setScale(5.0);
                player.move([startTile]);
                playerSprite.scaleX.animateTo(0.15, 1, flambe.animation.Ease.bounceOut);
                playerSprite.scaleY.animateTo(0.15, 1, flambe.animation.Ease.bounceOut);
                playerSprite.alpha.animateTo(1, 1, flambe.animation.Ease.bounceOut);
            }),
            new Delay(0.3),
            new CallFunction(function() {
                // var startTileSprite = startTile.get(Sprite);
                // emitter.setXY(startTileSprite.x._, startTileSprite.y._);
                // emitter.restart();
                // _ctx.playExplosion();
                spawnPlayerScript.dispose();
            }),
        ]));
    }

    private function getPathTo(x: Int, y :Int) :Array<Entity> {
        function tileIdToXY(tileId :String) {
            var idParts :Array<String> = tileId.split(",");
            var x :Int = Std.parseInt(idParts[0]);
            var y :Int = Std.parseInt(idParts[1]);
            return { x: x, y: y };
        }
        function XYToTileId(x :Int, y :Int) {
            return x + "," + y;
        }
        var getNeighbors = function(tileId) {
            var tilePos = tileIdToXY(tileId);
            var x :Int = tilePos.x;
            var y :Int = tilePos.y;
            var fromTile = tilemap.getTile(x, y);
            var fromTileData = fromTile.get(TileData);

            var neighbors = new Array<String>();
            var addIfPassable = function(toX :Int, toY :Int) {
                var toTile = tilemap.getTile(toX, toY);
                if (!canMoveToTile(fromTile, toTile)) return;
                neighbors.push(toX + "," + toY);
            };
            if (x + 1 < tilemap.getWidth()) addIfPassable(x + 1, y);
            if (x - 1 >= 0) addIfPassable(x - 1, y);
            if (y + 1 < tilemap.getHeight()) addIfPassable(x, y + 1);
            if (y - 1 >= 0) addIfPassable(x, y - 1);
            return neighbors;
        };
        var getDistance = function(fromId, toId) {
            var from = tileIdToXY(fromId);
            var to = tileIdToXY(fromId);
            return (Math.abs(to.x - from.x) + Math.abs(to.y - from.y));
        };

        var player = playerEntity.get(Player);
        if (player._tile == null) return [];
        var playerTileData = player._tile.get(TileData);
        var playerTileX = playerTileData.tileX;
        var playerTileY = playerTileData.tileY;
        
        var path = AStar.getPath(XYToTileId(playerTileX, playerTileY), XYToTileId(x, y), getNeighbors, getDistance);
        path.shift(); // Remove own position
        return [for (p in path) { var tile = tileIdToXY(p); tilemap.getTile(tile.x, tile.y); }];
    }

    override public function onUpdate (dt :Float) {
        
    }

    function canMoveToTile (fromTile :Entity, toTile :Entity) {
        var fromTileData = fromTile.get(TileData);
        var toTileData = toTile.get(TileData);
        if (toTileData.tileX < fromTileData.tileX && (!fromTile.has(TilePath.LeftOpen) || !toTile.has(TilePath.RightOpen)))  return false;
        if (toTileData.tileX > fromTileData.tileX && (!fromTile.has(TilePath.RightOpen)  || !toTile.has(TilePath.LeftOpen)))   return false;
        if (toTileData.tileY < fromTileData.tileY && (!fromTile.has(TilePath.TopOpen)    || !toTile.has(TilePath.BottomOpen))) return false;
        if (toTileData.tileY > fromTileData.tileY && (!fromTile.has(TilePath.BottomOpen) || !toTile.has(TilePath.TopOpen)))    return false;
        return true;
    }

    function shake(x :Float, y :Float, duration :Float) {
        var shakeScript = new Script();
        owner.add(shakeScript);
        shakeScript.run(new Shake(x, y, duration));
    }

    function moveRow(index :Int, direction :Float) {
        tilemap.moveRow(index, direction);
        centerTiles();
        shake(2, 1, 0.4);
    }

    function displaceRow(index :Int, amount :Float) {
        for (tile in tilemap.getRow(index)) {
            if (!tile.has(Sprite)) continue;
            var tileData = tile.get(TileData);
            var sprite = tile.get(ImageSprite);
            sprite.x._ = tilemap.tileToView(tileData.tileX) + amount;
        }
    }

    function displaceColumn(index :Int, amount :Float) {
        for (tile in tilemap.getColumn(index)) {
            if (!tile.has(Sprite)) continue;
            var tileData = tile.get(TileData);
            var sprite = tile.get(ImageSprite);
            sprite.y._ = tilemap.tileToView(tileData.tileY) + amount;
        }
    }

    function moveColumn(index :Int, direction :Float) {
        tilemap.moveColumn(index, direction);
        centerTiles();
        shake(1, 2, 0.4);
    }

    function centerTiles() {
        for (row in tilemap.getRows()) {
            for (tile in row) {
                var tileData = tile.get(TileData);
                var sprite = tile.get(ImageSprite);
                sprite.x.animateTo(tilemap.tileToView(tileData.tileX), 1, Ease.elasticOut);
                sprite.y.animateTo(tilemap.tileToView(tileData.tileY), 1, Ease.elasticOut);
            }
        }
    }
}


package ludumdare;

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
        tilemap = new TileMap(tileSize, width, height);
        moves = new Value<Int>(0);
    }

    override public function onAdded ()
    {
        tilemap.init();

        var mouseDown = false;
        var startTileX :Float = 0; 
        var startTileY :Float = 0;

        var emitterMold :EmitterMold = new EmitterMold(_ctx.pack, "particles/explode");
        var emitter :EmitterSprite = emitterMold.createEmitter();
        var emitterEntity :Entity = new Entity().add(emitter);

        // TODO: Should be:
        // tilemap = levelLoader.load(_file);

        var rawlevel :String = _ctx.pack.getFile(_file).toString();
        var lines = rawlevel.split("\n");

        for (y in 0...tilemap.getHeight()) {
            for (x in 0...tilemap.getWidth()) {
                var entity = tilemap.getTile(x, y);
                var rotation = Math.floor(Math.random() * 4);
                var random = Math.random();

                var type = lines[y].charAt(x);
                switch (type) {
                    case "│": entity.add(new StraightTile(_ctx, x, y, rotation = 0));
                    case "─": entity.add(new StraightTile(_ctx, x, y, rotation = 1));
                    case "└": entity.add(new BendTile(_ctx, x, y, rotation = 0));
                    case "┌": entity.add(new BendTile(_ctx, x, y, rotation = 1));
                    case "┐": entity.add(new BendTile(_ctx, x, y, rotation = 2));
                    case "┘": entity.add(new BendTile(_ctx, x, y, rotation = 3));
                    case " ": entity.add(new EmptyTile(_ctx, x, y, rotation));
                    case "╧": entity.add(new GoalTile(_ctx, x, y, rotation = 0));
                    case "╟": entity.add(new GoalTile(_ctx, x, y, rotation = 1));
                    case "╤": entity.add(new GoalTile(_ctx, x, y, rotation = 2));
                    case "╢": entity.add(new GoalTile(_ctx, x, y, rotation = 3));
                    case "G": entity.add(new GrassTile(_ctx, x, y, rotation));
                    case "█": entity.add(new BlockTile(_ctx, x, y, rotation));
                    default: trace("Unkown tile type: ", type);
                }

                var tileSprite = entity.get(Sprite);
                tileSprite.centerAnchor();
                tileSprite.setXY(tilemap.getViewWidth() / 2, tilemap.getViewHeight() / 2);
                tileSprite.x.animateTo(tilemap.tileToView(x), 1 + Math.random(), Ease.elasticOut);
                tileSprite.y.animateTo(tilemap.tileToView(y), 1 + Math.random(), Ease.elasticOut);
                tileSprite.scaleX.animateTo(1.0, 1 + Math.random(), Ease.elasticOut);
                tileSprite.scaleY.animateTo(1.0, 1 + Math.random(), Ease.elasticOut);
                var rotations = [0.0, 90.0, 180.0, 270.0];
                tileSprite.rotation.animateTo(rotations[rotation], 1 + Math.random(), Ease.elasticOut);

                entity.add(tileSprite);
                owner.addChild(entity);

                var tileData = entity.get(TileData);

                tileSprite.pointerDown.connect(function(event :PointerEvent) {
                    mouseDown = true;
                    startTileX = tileData.tileX;
                    startTileY = tileData.tileY;
                });
                tileSprite.pointerUp.connect(function(event :PointerEvent) {
                    if (!mouseDown) return;

                    mouseDown = false;
                    var tileX = tileData.tileX;
                    var tileY = tileData.tileY;
                    if (Math.abs(tileX - startTileX) == 0 && Math.abs(tileY - startTileY) == 0) {
                        // TODO: particle effect?
                        // if (empty) return;
                        var player = playerEntity.get(Player);
                        if (player._tile == null) return;
                        var playerTileData = player._tile.get(TileData);
                        var playerTileX = playerTileData.tileX;
                        var playerTileY = playerTileData.tileY;
                        var playerSprite = playerEntity.get(Sprite);
                        var path = getPathTo(tileX, tileY);
                        trace("path length", path.length);
                        player.move(path);
                        // if (Math.abs(playerTileX - tileX) + Math.abs(playerTileY - tileY) == 1) {
                        //     if (canMoveToTile(playerTileData, tileData)) {
                        //         player.moveToTile(tileSprite.owner);
                        //         _ctx.playJump();
                        //         moves._++;
                        //     }
                        // }
                        return;
                    }
                    if (Math.abs(tileX - startTileX) != 0 && Math.abs(tileY - startTileY) != 0) return;
                    if (Math.abs(tileX - startTileX) != 0) {
                        var hasBlock = false;
                        for (tile in tilemap.getRow(tileY)) {
                            if (tile.has(BlockTile)) {
                                var shakeScript = new Script();
                                tile.add(shakeScript);
                                shakeScript.run(new Shake(5, 5, 0.5));
                                emitter.setXY(tile.get(Sprite).x._, tile.get(Sprite).y._);
                                emitter.restart();
                                // _ctx.playHurt();
                                hasBlock = true;
                            }
                        }
                        if (hasBlock) return;
                        moveRow(tileY, tileX - startTileX);
                        // _ctx.playExplosion();
                        moves._++;
                    } else if (Math.abs(tileY - startTileY) != 0) {
                        var hasBlock = false;
                        for (tile in tilemap.getColumn(tileX)) {
                            if (tile.has(BlockTile)) {
                                var shakeScript = new Script();
                                tile.add(shakeScript);
                                shakeScript.run(new Shake(5, 5, 0.5));
                                emitter.setXY(tile.get(Sprite).x._, tile.get(Sprite).y._);
                                emitter.restart();
                                // _ctx.playHurt();
                                hasBlock = true;
                            }
                        }
                        if (hasBlock) return;
                        moveColumn(tileX, tileY - startTileY);
                        // _ctx.playExplosion();
                        moves._++;
                    }
                });
            }
        }

        // Create the player's sprite
        var player = new Player(_ctx, "player/player");
        playerEntity = new Entity().add(player);
        owner.addChild(playerEntity);
        owner.addChild(emitterEntity);

        var playerSprite = playerEntity.get(Sprite);
        playerSprite.setAlpha(0.0);

        var startX = 2;
        var startY = 2;
        // HACK to get the players position
        if (lines.length >= tilemap.getHeight()) {
            var startStr = lines[tilemap.getHeight()].split(",");
            startX = Std.parseInt(startStr[0]);
            startY = Std.parseInt(startStr[1]);
        }

        var spawnPlayerScript = new Script();
        owner.add(spawnPlayerScript);
        spawnPlayerScript.run(new Sequence([
            new Shake(2, 2, 0.5),
            new CallFunction(function() {
                var startTile = tilemap.getTile(startX, startY); // TODO: Get this information from the level data
                var startTileSprite = startTile.get(Sprite);
                playerSprite.setXY(startTileSprite.x._, startTileSprite.y._);
                playerSprite.setScale(5.0);
                player.move([startTile]);
                playerSprite.scaleX.animateTo(0.75, 1, flambe.animation.Ease.bounceOut);
                playerSprite.scaleY.animateTo(0.75, 1, flambe.animation.Ease.bounceOut);
                playerSprite.alpha.animateTo(1, 1, flambe.animation.Ease.bounceOut);
            }),
            new Delay(0.3),
            new CallFunction(function() {
                var startTile = tilemap.getTile(startX, startY);
                var startTileSprite = startTile.get(Sprite);
                emitter.setXY(startTileSprite.x._, startTileSprite.y._);
                emitter.restart();
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
            var tile = tileIdToXY(tileId);
            var x :Int = tile.x;
            var y :Int = tile.y;
            var fromTileData = tilemap.getTile(x, y).get(TileData);

            var neighbors = new Array<String>();
            var addIfPassable = function(toX :Int, toY :Int) {
                var toTileData = tilemap.getTile(toX, toY).get(TileData);
                if (!canMoveToTile(fromTileData, toTileData)) return;
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

    function canMoveToTile (fromTile :TileData, toTile :TileData) {
        if (toTile.tileX < fromTile.tileX && (!fromTile.leftOpen   || !toTile.rightOpen))  return false;
        if (toTile.tileX > fromTile.tileX && (!fromTile.rightOpen  || !toTile.leftOpen))   return false;
        if (toTile.tileY < fromTile.tileY && (!fromTile.topOpen    || !toTile.bottomOpen)) return false;
        if (toTile.tileY > fromTile.tileY && (!fromTile.bottomOpen || !toTile.topOpen))    return false;
        return true;
    }

    function moveRow(index :Int, direction :Float) {
        tilemap.moveRow(index, direction);
        var count = 0;
        for (tile in tilemap.getRow(index)) {
            var tileData = tile.get(TileData);
            tileData.tileX = count;
            var sprite = tile.get(ImageSprite);
            sprite.x.animateTo(tilemap.tileToView(count), 1, Ease.elasticOut);
            count++;
        }
        var shakeScript = new Script();
        owner.add(shakeScript);
        shakeScript.run(new Shake(2, 1, 0.4));
    }

    function moveColumn(index :Int, direction :Float) {
        var column = tilemap.getColumn(index);
        if (direction > 0) {
            column.unshift(column.pop());
        } else if (direction < 0) {
            column.push(column.shift());
        }
        for (y in 0...column.length) {
            var tile = column[y];
            var tileData = tile.get(TileData);
            tileData.tileY = y;
            var sprite = tile.get(ImageSprite);
            sprite.y.animateTo(tilemap.tileToView(y), 1, Ease.elasticOut);
            tilemap.setTile(tile, index, y);
        }
        var shakeScript = new Script();
        owner.add(shakeScript);
        shakeScript.run(new Shake(2, 1, 0.4));
    }
}

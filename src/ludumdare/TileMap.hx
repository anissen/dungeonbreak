
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
class TileMap extends Component
{
    public function new (ctx :GameContext, file :String, tileSize :Int, width :Int, height :Int)
    {
        _ctx = ctx;
        _file = file;
        TILE_SIZE = tileSize;
        WIDTH = width;
        HEIGHT = height;
        moves = new Value<Int>(0);
    }

    override public function onAdded ()
    {
        tiles = [
            for (y in 0...8) [ 
                for (x in 0...5)
                    new Entity() 
            ]
        ];

        var mouseDown = false;
        var startTileX :Float = 0; 
        var startTileY :Float = 0;

        var emitterMold :EmitterMold = new EmitterMold(_ctx.pack, "particles/explode");
        var emitter :EmitterSprite = emitterMold.createEmitter();
        var emitterEntity :Entity = new Entity().add(emitter);

        var rawlevel :String = _ctx.pack.getFile(_file).toString();
        var lines = rawlevel.split("\n");

        for (y in 0...8) {
            for (x in 0...5) {
                var entity = tiles[y][x];
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
                tileSprite.setXY(WIDTH / 2, HEIGHT / 2);
                tileSprite.x.animateTo(x * TILE_SIZE + TILE_SIZE / 2, 1 + Math.random(), Ease.elasticOut);
                tileSprite.y.animateTo(y * TILE_SIZE + TILE_SIZE / 2, 1 + Math.random(), Ease.elasticOut);
                tileSprite.scaleX.animateTo(1.0, 1 + Math.random(), Ease.elasticOut);
                tileSprite.scaleY.animateTo(1.0, 1 + Math.random(), Ease.elasticOut);
                var rotations = [0.0, 90.0, 180.0, 270.0];
                tileSprite.rotation.animateTo(rotations[rotation], 1 + Math.random(), Ease.elasticOut);

                var entity = tiles[y][x];
                entity.add(tileSprite);
                owner.addChild(entity);

                var tileData = entity.get(TileData);

                tileSprite.pointerDown.connect(function(event :PointerEvent) {
                    mouseDown = true;
                    startTileX = tileData.tileX;
                    startTileY = tileData.tileY;
                    // selection.setXY(startTileX * TILE_SIZE + TILE_SIZE / 2, startTileY * TILE_SIZE + TILE_SIZE / 2);
                    // selection.scaleX.animateTo(1.0, 0.5, Ease.elasticOut);
                    // selection.scaleY.animateTo(1.0, 0.5, Ease.elasticOut);
                    // selection.alpha.animateTo(1.0, 0.5, Ease.elasticOut);
                });
                tileSprite.pointerUp.connect(function(event :PointerEvent) {
                    if (!mouseDown) return;
                    // selection.scaleX.animateTo(0.0, 0.5, Ease.elasticOut);
                    // selection.scaleY.animateTo(0.0, 0.5, Ease.elasticOut);
                    // selection.alpha.animateTo(0.0, 0.5, Ease.elasticOut);

                    mouseDown = false;
                    var tileX = tileData.tileX; // Math.floor(event.viewX / TILE_SIZE);
                    var tileY = tileData.tileY; // Math.floor(event.viewY / TILE_SIZE);
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
                        for (tile in getRow(tileY)) {
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
                        for (tile in getColumn(tileX)) {
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

        var spawnPlayerScript = new Script();
        owner.add(spawnPlayerScript);
        spawnPlayerScript.run(new Sequence([
            new Shake(2, 2, 0.5),
            new CallFunction(function() {
                var startTile = tiles[2][2];
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
                var startTile = tiles[2][2];
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

            var neighbors = new Array<String>();
            var addIfPassable = function(x :Int, y :Int) {
                if (x == 1 && y == 0) return;
                neighbors.push(x + "," + y);
            };
            if (x + 1 < 5) addIfPassable(x + 1, y);
            if (x - 1 >= 0) addIfPassable(x - 1, y);
            if (y + 1 < 8) addIfPassable(x, y + 1);
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
        return [for (p in path) { var tile = tileIdToXY(p); tiles[tile.y][tile.x]; }];
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

    function getRow(index :Int) {
        return tiles[index];
    }

    function getColumn(index :Int) {
        var column = new Array<Entity>();
        for (row in tiles) {
            column.push(row[index]);
        }
        return column;
    }

    function moveRow(index :Int, direction :Float) {
        var row = tiles[index];
        if (direction > 0) {
            row.unshift(row.pop());
        } else if (direction < 0) {
            row.push(row.shift());
        }
        var count = 0;
        for (tile in row) {
            var tileData = tile.get(TileData);
            tileData.tileX = count;
            var sprite = tile.get(ImageSprite);
            sprite.x.animateTo(count * TILE_SIZE + TILE_SIZE / 2, 1, Ease.elasticOut);
            // if (tile.has(EmitterSprite)) {
            //     tile.get(EmitterSprite).restart();
            // }
            count++;
        }
        var shakeScript = new Script();
        owner.add(shakeScript);
        shakeScript.run(new Shake(2, 1, 0.4));
    }

    function moveColumn(index :Int, direction :Float) {
        var column = new Array<Entity>();
        for (row in tiles) {
            column.push(row[index]);
        }
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
            sprite.y.animateTo(y * TILE_SIZE + TILE_SIZE / 2, 1, Ease.elasticOut);
            tiles[y][index] = tile;
        }
        var shakeScript = new Script();
        owner.add(shakeScript);
        shakeScript.run(new Shake(2, 1, 0.4));
    }

    private var _ctx :GameContext;
    private var _name :String;
    private var _file :String;
    private var _moveSpeed :Float = 200;

    private var TILE_SIZE :Int;
    private var HEIGHT :Int;
    private var WIDTH :Int;

    private var tiles :Array<Array<Entity>>;

    public var _engineSoundPlayback :Playback;

    public var playerEntity (default, null) :Entity;
    public var moves (default, null) :Value<Int>;
}

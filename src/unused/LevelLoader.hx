
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
class LevelLoader extends Component
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

    public static function load (ctx :GameContext, file :String, tileSize :Int, width :Int, height :Int)
    {
        tilemap.init();

        var rawlevel :String = ctx.pack.getFile(_file).toString();
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
            }
        }

        // Create the player's sprite
        var player = new Player(_ctx, "player/star");
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
                var startTile = tilemap.getTile(2, 2); // TODO: Get this information from the level data
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
                var startTile = tilemap.getTile(2, 2);
                var startTileSprite = startTile.get(Sprite);
                emitter.setXY(startTileSprite.x._, startTileSprite.y._);
                emitter.restart();
                // _ctx.playExplosion();
                spawnPlayerScript.dispose();
            }),
        ]));
    }
}

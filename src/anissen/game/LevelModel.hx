
package anissen.game;

import flambe.Component;
import flambe.display.FillSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.Point;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Parallel;
import flambe.script.Script;
import flambe.SpeedAdjuster;
import flambe.System;
import flambe.animation.Ease;
import flambe.display.ImageSprite;
import flambe.display.PatternSprite;
import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.script.*;
import flambe.animation.AnimatedFloat;
import flambe.util.Value;
import flambe.display.TextSprite;
import flambe.display.Font;
import flambe.display.EmitterMold;
import flambe.display.EmitterSprite;

class LevelModel extends Component
{
    public function new (ctx :GameContext)
    {
        _ctx = ctx;
        _zoom = new AnimatedFloat(1);
        moves = new Value<Int>(0);
    }

    override public function onAdded ()
    {
        _worldLayer = new Entity();
        _worldLayer.add(new Sprite().centerAnchor()); // Dummy sprite to be able to scale the entire scene
        var ratio :Float = FMath.min(System.stage.width / (WIDTH * TILE_SIZE), System.stage.height / (HEIGHT * TILE_SIZE));
        _worldLayer.get(Sprite).setScale(ratio);
        owner.addChild(_worldLayer);

        // Add a scrolling ocean background
        var background = new PatternSprite(_ctx.pack.getTexture("backgrounds/skulls2"), System.stage.width * 2, System.stage.height * 2);
        background.setScale(2);
        background.disablePixelSnapping();
        _worldLayer.addChild(new Entity().add(background).add(new BackgroundScroller(10, 30)));
        _worldLayer.addChild(_mapLayer = new Entity());

        loadMap(_levelIndex);
    }

    private function loadMap(index :Int) {
        _mapLayer.disposeChildren();
        var map = new LevelMap(_ctx, "levels/level" + index + ".json", TILE_SIZE, WIDTH, HEIGHT);
        _mapLayer.add(new Sprite());
        _mapLayer.add(map);

        totalMoves += moves._;
        map.moves.watch(function (movesOnMap, _) {
            moves._ = /* totalMoves + */ movesOnMap;
        });

        // var levelMessage :String = _ctx.messages.get("level" + index, [totalMoves]);
        // if (levelMessage != "level" + index) { 
        //     var worldSpeed = new SpeedAdjuster(0.5);
        //     _worldLayer.add(worldSpeed);

        //     var showPromptScript = new Script();
        //     owner.add(showPromptScript);
        //     showPromptScript.run(new Sequence([
        //         new CallFunction(function() {
        //             // Adjust the speed of the world for a dramatic slow motion effect
        //             worldSpeed.scale.animateTo(0.0, 1);
        //         }),
        //         new Delay(1),
        //         new CallFunction(function() {
        //             _ctx.showPrompt(_ctx.messages.get("info_heading", [index]), levelMessage, [
        //                 "play", function () {
        //                     // Unpause by unwinding to the original scene
        //                     _ctx.director.unwindToScene(owner);
        //                     worldSpeed.scale.animateTo(1.0, 1);
        //                 }
        //             ]);
        //             showPromptScript.dispose();
        //         })
        //     ]));
        // }
        
        var player = map.playerEntity.get(Player);
        player.onWin.connect(function() {
            // _ctx.playPowerup();
            loadMap(++_levelIndex);
        });
    }

    override public function onUpdate (dt :Float)
    {

    }

    private var _ctx :GameContext;

    private var _worldLayer  :Entity;
    private var _mapLayer  :Entity;
    private var _playerLayer  :Entity;
    private var _zoom :AnimatedFloat;
    private var _moving :Bool = false;
    private var _levelIndex :Int = 1;
    private static var TILE_SIZE :Int = 128;
    private static var WIDTH :Int = 5; // 640;
    private static var HEIGHT :Int = 8; // 1024

    public var totalMoves :Int = 0;
    public var moves (default, null) :Value<Int>;
}

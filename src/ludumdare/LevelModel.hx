
package ludumdare;

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
        owner.addChild(_worldLayer);

        // Add a scrolling ocean background
        var background = new PatternSprite(_ctx.pack.getTexture("backgrounds/background"), WIDTH, HEIGHT);
        background.setScale(2);
        _worldLayer.addChild(new Entity().add(background).add(new BackgroundScroller(100)));
        _worldLayer.addChild(_mapLayer = new Entity());

        loadMap(_levelIndex);
        // speak("System operational");
    }

    private function loadMap(index :Int) {
        _mapLayer.disposeChildren();
        var map = new Map(_ctx, "levels/level" + index + ".lvl", TILE_SIZE, WIDTH, HEIGHT);
        _mapLayer.add(new Sprite());
        _mapLayer.add(map);

        totalMoves += moves._;
        map.moves.watch(function (movesOnMap, _) {
            moves._ = /* totalMoves + */ movesOnMap;
        });

        var levelMessage :String = _ctx.messages.get("level" + index, [totalMoves]);
        if (levelMessage != "level" + index) { 
            var worldSpeed = new SpeedAdjuster(0.5);
            _worldLayer.add(worldSpeed);

            var showPromptScript = new Script();
            owner.add(showPromptScript);
            showPromptScript.run(new Sequence([
                new CallFunction(function() {
                    // Adjust the speed of the world for a dramatic slow motion effect
                    worldSpeed.scale.animateTo(0.0, 1);
                }),
                new Delay(1),
                new CallFunction(function() {
                    _ctx.showPrompt(_ctx.messages.get("info_heading", [index]), levelMessage, [
                        "play", function () {
                            // Unpause by unwinding to the original scene
                            _ctx.director.unwindToScene(owner);
                            worldSpeed.scale.animateTo(1.0, 1);
                        }
                    ]);
                    showPromptScript.dispose();
                })
            ]));
        }
        
        var player = map.playerEntity.get(Player);
        player.onWin.connect(function() {
            _ctx.playPowerup();
            loadMap(++_levelIndex);
        });
    }

    private function speak (text :String) {
        #if js
        js.Lib.eval("speak('" + text + "', 33)");
        #end
    }

    private function onPlanetMouseEnter (event :PointerEvent) {
        trace("Entered planet " + event.hit.name);
    }

    private function onPlanetMouseLeave (event :PointerEvent) {
        trace("Left planet " + event.hit.name);
    }

    private function onPlanetMouseClick (event :PointerEvent) {
        var planet = event.hit.owner;
        trace("Clicked planet " + event.hit.name);

        // speak("Moving to " + planet.get(Planet).planetName);
    }

    override public function onUpdate (dt :Float)
    {
        // var playerSprite = player.get(Sprite);
        // var worldSprite = _worldLayer.get(Sprite);

        // if (System.mouse.isDown(flambe.input.MouseButton.Left)) {
        //     var pointerX = worldSprite.anchorX._ + System.mouse.x * (1 / _zoom._);
        //     var pointerY = worldSprite.anchorY._ + System.mouse.y * (1 / _zoom._);
        //     var spaceship = player.get(Player);
        //     spaceship.move(pointerX, pointerY);
        // }
        // _zoom.update(dt);
        // // _zoom._ = FMath.clamp(_zoom._ + (_moving ? -2 * dt : 2 * dt), 0.7, 2);
        // worldSprite
        //     .setScale(_zoom._)
        //     .setAnchor(playerSprite.x._ - (System.stage.width / 2) / _zoom._, playerSprite.y._ - (System.stage.height / 2) / _zoom._);
    }

    private var _ctx :GameContext;

    private var _worldLayer  :Entity;
    private var _mapLayer  :Entity;
    private var _playerLayer  :Entity;
    private var _zoom :AnimatedFloat;
    private var _moving :Bool = false;
    private var _levelIndex :Int = 1;
    private static var TILE_SIZE :Int = 128;
    private static var HEIGHT :Int = TILE_SIZE * 5; // 640;
    private static var WIDTH :Int = TILE_SIZE * 7; //approx. 960;

    public var totalMoves :Int = 0;
    public var moves (default, null) :Value<Int>;
}


package ludumdare;

import flambe.animation.Ease;
import flambe.Component;
import flambe.display.ImageSprite;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.math.FMath;
import flambe.script.*;
import flambe.script.CallFunction;
import flambe.script.MoveTo;
import flambe.sound.Sound;
import flambe.sound.Playback;
import flambe.util.Signal0;
import flambe.display.EmitterSprite;

/** Logic for player. */
class Player extends Component
{
    public function new (ctx :GameContext, name :String)
    {
        _ctx = ctx;
        _name = name;
        _movePath = new Array<Entity>();
    }

    override public function onAdded ()
    {
        var normal = _ctx.pack.getTexture(_name);
        _sprite = owner.get(ImageSprite);
        if (_sprite == null) {
            owner.add(_sprite = new ImageSprite(normal));
        }
        _sprite.texture = normal;
        // _sprite.setScale(0.1);
        _sprite.disablePixelSnapping();
        _sprite.disablePointer();
        _sprite.centerAnchor();
    }

    override public function onUpdate (dt :Float) {
        if (_movePath.length == 0) {
            if (_tile != null) {
                var tileSprite = _tile.get(ImageSprite);
                _sprite.setXY(tileSprite.x._, tileSprite.y._);
            }
            return;
        }

        var nextTile = _movePath[0];
        _tile = nextTile;
        var tileSprite = nextTile.get(Sprite);
        var diffX = tileSprite.x._ - _sprite.x._;
        var diffY = tileSprite.y._ - _sprite.y._;
        var distance = Math.sqrt(Math.pow(diffX, 2) + Math.pow(diffY, 2));
        if (distance < 10) {
            if (nextTile.has(GoalTile)) {
                onWin.emit();
            }
            _movePath.shift();
            return;
        }
        _sprite.x._ += diffX * _moveSpeed * dt;
        _sprite.y._ += diffY * _moveSpeed * dt;
    }

    public function move (tiles :Array<Entity>) {
        _movePath = tiles;
        // if (tiles.length == 0) return;

        // var distance = 2; //(Math.sqrt(Math.pow(tileSprite.x._ - _sprite.x._, 2) + Math.pow(tileSprite.y._ - _sprite.y._, 2))) / _moveSpeed;

        // // TODO: Make this into a Component
        // var moveScript = new Script();
        // owner.add(moveScript);
        // var moveSequence = new Sequence();
        // var count = 0;
        // for (tile in tiles) {
        //     count++;
        //     var tileSprite = tile.get(Sprite);
        //     moveSequence.add(new MoveTo(tileSprite.x._, tileSprite.y._, distance * count, Ease.elasticOut, Ease.elasticOut));
        //     moveSequence.add(new Delay(1));
        //     moveSequence.add(new CallFunction(function () {
        //         trace("call function");
        //         _tile = tile;
        //         if (tile.has(GoalTile)) {
        //             onWin.emit();
        //         }
        //     }));
        // }
        // moveSequence.add(new CallFunction(function () {
        //     moveScript.dispose();
        // }));
        // moveScript.run(moveSequence);
        // _tile = null;

    }

    private var _ctx :GameContext;
    private var _name :String;
    private var _sprite :ImageSprite;
    private var _moveSpeed :Float = 10;
    private var _script :Script;
    private var _moveToX :Float;
    private var _moveToY :Float;
    public var _tile :Entity;
    private var _movePath :Array<Entity>;
    public var onWin :Signal0 = new Signal0();
}

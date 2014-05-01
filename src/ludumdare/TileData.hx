
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
import flambe.sound.Sound;
import flambe.sound.Playback;
import flambe.util.Signal1;
import flambe.display.EmitterSprite;

class TileData extends Component
{
    public function new ()
    {

    }

    override public function onAdded ()
    {
        // var mouseDown = false;
        // var sprite = owner.get(FillSprite);
        // sprite.pointerDown.connect(function(event :PointerEvent) {
        //     mouseDown = true;
        // });
        // sprite.pointerUp.connect(function(event :PointerEvent) {
        //     if (!mouseDown) return;
        //     mouseDown = false;
        //     trace("clicked!");
        // });
    }

    override public function onUpdate (dt :Float) {
        
    }

    public var tileX :Int;
    public var tileY :Int;
    public var topOpen :Bool;
    public var bottomOpen :Bool;
    public var leftOpen :Bool;
    public var rightOpen :Bool;
}

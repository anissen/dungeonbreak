
package anissen.game;

import flambe.Component;
import flambe.animation.AnimatedFloat;
import flambe.display.Sprite;

class BackgroundScroller extends Component
{
    public var xspeed :AnimatedFloat;
    public var yspeed :AnimatedFloat;

    public function new (xspeed :Float, yspeed :Float)
    {
        this.xspeed = new AnimatedFloat(xspeed);
        this.yspeed = new AnimatedFloat(yspeed);
    }

    override public function onUpdate (dt :Float)
    {
        xspeed.update(dt);
        yspeed.update(dt);

        var sprite = owner.get(Sprite);
        sprite.y._ += dt * yspeed._;
        sprite.x._ += dt * xspeed._;
        while (sprite.y._ > 0) {
            sprite.y._ -= 800;
        }
        while (sprite.x._ > 0) {
            sprite.x._ -= 800;
        }
    }
}

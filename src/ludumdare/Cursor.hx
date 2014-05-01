
package ludumdare;

import flambe.Component;
import flambe.display.ImageSprite;

/** Logic for planes. */
class Cursor extends Component
{
    public function new (ctx :GameContext, name :String)
    {
        _ctx = ctx;
        _name = name;
    }

    override public function onAdded ()
    {
        var normal = _ctx.pack.getTexture(_name);
        var sprite = owner.get(ImageSprite);
        if (sprite == null) {
            owner.add(sprite = new ImageSprite(normal));
        }
        sprite.texture = normal;
        sprite.centerAnchor();
        sprite.disablePointer();

        sprite.scaleX.animateTo(0.1, 1, flambe.animation.Ease.bounceOut);
        sprite.scaleY.animateTo(0.1, 1, flambe.animation.Ease.bounceOut);
    }

    private var _ctx :GameContext;
    private var _name :String;
}

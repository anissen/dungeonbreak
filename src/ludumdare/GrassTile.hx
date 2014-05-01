
package ludumdare;

import flambe.Component;
import flambe.display.ImageSprite;

class GrassTile extends Component
{
    public function new (ctx :GameContext, x :Int, y :Int, rotation :Int)
    {
        _ctx = ctx;
        _tileX = x;
        _tileY = y;
        _rotation = rotation;
    }

    override public function onAdded ()
    {
        var texture = _ctx.pack.getTexture("tiles/grass");
        var sprite = new ImageSprite(texture);
        owner.add(sprite);

        var tileData = new TileData();
        tileData.tileX = _tileX;
        tileData.tileY = _tileY;
        tileData.topOpen    = true;
        tileData.bottomOpen = true;
        tileData.leftOpen   = true;
        tileData.rightOpen  = true;
        owner.add(tileData);
    }

    private var _ctx :GameContext;
    private var _tileX :Int;
    private var _tileY :Int;
    private var _rotation :Int;
}

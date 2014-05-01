
package ludumdare;

import flambe.Component;
import flambe.display.ImageSprite;

class EmptyTile extends Component
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
        var texture = _ctx.pack.getTexture("tiles/empty");
        var sprite = new ImageSprite(texture);
        owner.add(sprite);

        var tileData = new TileData();
        tileData.tileX = _tileX;
        tileData.tileY = _tileY;
        tileData.topOpen    = false;
        tileData.bottomOpen = false;
        tileData.leftOpen   = false;
        tileData.rightOpen  = false;
        owner.add(tileData);
    }

    private var _ctx :GameContext;
    private var _tileX :Int;
    private var _tileY :Int;
    private var _rotation :Int;
}

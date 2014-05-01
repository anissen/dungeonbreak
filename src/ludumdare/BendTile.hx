
package ludumdare;

import flambe.Component;
import flambe.display.ImageSprite;

class BendTile extends Component
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
        var texture = _ctx.pack.getTexture("tiles/bend");
        var sprite = new ImageSprite(texture);
        owner.add(sprite);

        var tileData = new TileData();
        tileData.tileX = _tileX;
        tileData.tileY = _tileY;
        tileData.topOpen    = (_rotation == 0 || _rotation == 3);
        tileData.bottomOpen = (_rotation == 1 || _rotation == 2);
        tileData.leftOpen   = (_rotation == 2 || _rotation == 3);
        tileData.rightOpen  = (_rotation == 0 || _rotation == 1);
        owner.add(tileData);
    }

    private var _ctx :GameContext;
    private var _tileX :Int;
    private var _tileY :Int;
    private var _rotation :Int;
}

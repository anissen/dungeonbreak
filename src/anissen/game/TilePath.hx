
package anissen.game;

import flambe.Component;

class TilePath extends Component
{
    // TODO: Make this into a struct instead, so it can be initialize like { left: true, top: true }
    public function new (top :Bool, bottom :Bool, left :Bool, right :Bool)
    {
        topOpen = top;
        bottomOpen = bottom;
        leftOpen = left;
        rightOpen = right;
    }

    public var topOpen :Bool;
    public var bottomOpen :Bool;
    public var leftOpen :Bool;
    public var rightOpen :Bool;
}

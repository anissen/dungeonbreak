
package anissen.game;

import flambe.animation.Ease;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.FMath;
import flambe.script.*;
import flambe.script.CallFunction;
import flambe.script.Shake;
import flambe.sound.Sound;
import flambe.sound.Playback;
import flambe.util.Signal1;
import flambe.display.EmitterSprite;
import flambe.display.EmitterMold;
import flambe.display.EmitterSprite;
import flambe.util.Value;

/** Logic for tile map. */
class TileMap
{
    private var _tileSize :Int;
    private var _height :Int;
    private var _width :Int;
    private var _tiles :Array<Array<Entity>>;

    public var onTileClicked = new flambe.util.Signal1<Entity>();
    public var onTileDragging = new flambe.util.Signal1<Entity>();
    public var onTileDragged = new flambe.util.Signal1<Entity>();

    public function new ()
    {
        _tileSize = 128; // TODO: HACK!
    }

    public function init (width :Int, height :Int)
    {
        _width = width;
        _height = height;
        _tiles = [
            for (y in 0...height) [ 
                for (x in 0...width)
                    new Entity()
            ]
        ];
    }

    public function getTile(x :Int, y :Int) :Entity
    {
        return _tiles[y][x];
    }

    public function setTile(tile :Entity, x :Int, y :Int)
    {
        _tiles[y][x] = tile;
    }

    public function tileToView(tilePosition :Int) :Int
    {
        return Math.round((tilePosition * _tileSize) + _tileSize / 2);
    }

    public function viewToTile(viewPosition :Int) :Int
    {
        return Math.floor((viewPosition + _tileSize / 2) / _tileSize);
    }

    public function getHeight() :Int
    {
        return _height;
    }

    public function getWidth() :Int
    {
        return _width;
    }

    public function getViewHeight() :Int
    {
        return _height * _tileSize;
    }

    public function getViewWidth() :Int
    {
        return _width * _tileSize;
    }

    public function getRows() {
        return _tiles;
    }

    public function getRow(index :Int) {
        return _tiles[index];
    }

    public function getColumn(index :Int) {
        var column = new Array<Entity>();
        for (row in _tiles) {
            column.push(row[index]);
        }
        return column;
    }

    public function moveRow(index :Int, direction :Float) {
        var row = _tiles[index];
        if (direction > 0) {
            row.unshift(row.pop());
        } else if (direction < 0) {
            row.push(row.shift());
        }
        var count = 0;
        for (tile in row) {
            var tileData = tile.get(TileData);
            tileData.tileX = count;
            count++;
        }
    }

    public function moveColumn(index :Int, direction :Float) {
        var column = new Array<Entity>();
        for (row in _tiles) {
            column.push(row[index]);
        }
        if (direction > 0) {
            column.unshift(column.pop());
        } else if (direction < 0) {
            column.push(column.shift());
        }
        for (y in 0...column.length) {
            var tile = column[y];
            var tileData = tile.get(TileData);
            tileData.tileY = y;
            _tiles[y][index] = tile;
        }
    }
}

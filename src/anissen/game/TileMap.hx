
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

    /*
    private function getPathTo(x: Int, y :Int) :Array<Entity> {
        function tileIdToXY(tileId :String) {
            var idParts :Array<String> = tileId.split(",");
            var x :Int = Std.parseInt(idParts[0]);
            var y :Int = Std.parseInt(idParts[1]);
            return { x: x, y: y };
        }
        function XYToTileId(x :Int, y :Int) {
            return x + "," + y;
        }
        var getNeighbors = function(tileId) {
            var tile = tileIdToXY(tileId);
            var x :Int = tile.x;
            var y :Int = tile.y;

            var neighbors = new Array<String>();
            var addIfPassable = function(x :Int, y :Int) {
                if (x == 1 && y == 0) return;
                neighbors.push(x + "," + y);
            };
            if (x + 1 < 5) addIfPassable(x + 1, y);
            if (x - 1 >= 0) addIfPassable(x - 1, y);
            if (y + 1 < 8) addIfPassable(x, y + 1);
            if (y - 1 >= 0) addIfPassable(x, y - 1);
            return neighbors;
        };
        var getDistance = function(fromId, toId) {
            var from = tileIdToXY(fromId);
            var to = tileIdToXY(fromId);
            return (Math.abs(to.x - from.x) + Math.abs(to.y - from.y));
        };

        var player = playerEntity.get(Player);
        if (player._tile == null) return [];
        var playerTileData = player._tile.get(TileData);
        var playerTileX = playerTileData.tileX;
        var playerTileY = playerTileData.tileY;
        
        var path = AStar.getPath(XYToTileId(playerTileX, playerTileY), XYToTileId(x, y), getNeighbors, getDistance);
        path.shift(); // Remove own position
        return [for (p in path) { var tile = tileIdToXY(p); _tiles[tile.y][tile.x]; }];
    }

    function canMoveToTile (fromTile :TileData, toTile :TileData) {
        if (toTile.tileX < fromTile.tileX && (!fromTile.leftOpen   || !toTile.rightOpen))  return false;
        if (toTile.tileX > fromTile.tileX && (!fromTile.rightOpen  || !toTile.leftOpen))   return false;
        if (toTile.tileY < fromTile.tileY && (!fromTile.topOpen    || !toTile.bottomOpen)) return false;
        if (toTile.tileY > fromTile.tileY && (!fromTile.bottomOpen || !toTile.topOpen))    return false;
        return true;
    }
    */

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

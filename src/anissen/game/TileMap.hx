
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
    private var TILE_SIZE :Int;
    private var HEIGHT :Int;
    private var WIDTH :Int;
    private var tiles :Array<Array<Entity>>;

    public function new (tileSize :Int, width :Int, height :Int)
    {
        TILE_SIZE = tileSize;
        WIDTH = width;
        HEIGHT = height;
    }

    public function init ()
    {
        tiles = [
            for (y in 0...HEIGHT) [ 
                for (x in 0...WIDTH)
                    new Entity() 
            ]
        ];

        // for (y in 0...HEIGHT) {
        //     for (x in 0...WIDTH) {
        //         var entity = tiles[y][x];
        //         // ??
        //     }
        // }
    }

    public function getTile(x :Int, y :Int) :Entity
    {
        return tiles[y][x];
    }

    public function setTile(tile :Entity, x :Int, y :Int)
    {
        tiles[y][x] = tile;
    }

    public function tileToView(position :Int) :Int
    {
        return Math.round((position * TILE_SIZE) + TILE_SIZE / 2);
    }

    public function getHeight() :Int
    {
        return HEIGHT;
    }

    public function getWidth() :Int
    {
        return WIDTH;
    }

    public function getViewHeight() :Int
    {
        return HEIGHT * TILE_SIZE;
    }

    public function getViewWidth() :Int
    {
        return WIDTH * TILE_SIZE;
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
        return [for (p in path) { var tile = tileIdToXY(p); tiles[tile.y][tile.x]; }];
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
        return tiles;
    }

    public function getRow(index :Int) {
        return tiles[index];
    }

    public function getColumn(index :Int) {
        var column = new Array<Entity>();
        for (row in tiles) {
            column.push(row[index]);
        }
        return column;
    }

    public function moveRow(index :Int, direction :Float) {
        var row = tiles[index];
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
        for (row in tiles) {
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
            tiles[y][index] = tile;
        }
    }
}

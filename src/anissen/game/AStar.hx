
package anissen.game;

import haxe.ds.StringMap;

typedef TilePathData = { tileId :String, prev :TilePathData, g :Int, h :Float };

class AStar
{
    public static function getPath (fromId :String, 
                             toId :String, 
                             neighborsFunc :(String -> Array<String>), 
                             distanceFunc :(String -> String -> Float)) :Array<String>
    {
        var todo = new Array<TilePathData>();
        var done = new StringMap<TilePathData>();

        function add(tileId :String, prev :TilePathData = null) {
            var obj :TilePathData = {
                tileId: tileId,
                prev: prev,
                g: (prev != null ? prev.g + 1 : 0), 
                h: distanceFunc(fromId, tileId)
            };
            done.set(tileId, obj);

            var f = obj.g + obj.h;
            for (i in 0...todo.length) {
                var item = todo[i];
                if (f < item.g + item.h) {
                    todo.insert(i, obj);
                    return;
                }
            }
            todo.push(obj);
        }

        add(toId);

        while (todo.length > 0) {
            var item = todo.shift();
            if (item.tileId == fromId) { break; }
            var neighbors = neighborsFunc(item.tileId);
            for (neighbor in neighbors) {
                if (done.exists(neighbor)) { continue; }
                add(neighbor, item);
            }
        }

        if (!done.exists(fromId)) { return []; }
        var item = done.get(fromId);
        var path = new Array<String>();
        while (item != null) {
            path.push(item.tileId);
            item = item.prev;
        }
        return path;
    }
}

// class TilePath {
//     public function getPath (fromId :String, 
//                              toId :String, 
//                              neighborsFunc :(String -> Array<String>), 
//                              distanceFunc :(String -> String -> Float)) :Array<String>
// }

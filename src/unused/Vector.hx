//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package ludumdare;

/**
 * A 2D vector.
 */
class Vector
{
    public var x :Float;
    public var y :Float;

    public function new (x :Float = 0, y :Float = 0)
    {
        this.x = x;
        this.y = y;
    }

    /**
     * Normalize this vector, so that its new magnitude is 1.
     */
    public function normalize () :Vector
    {
        var m = magnitude();
        return new Vector(x / m, y / m);
    }

    /**
     * Return the result of substract a vector from this vector.
     */
    public function substract (other :Vector) :Vector
    {
        return new Vector(this.x - other.x, this.y - other.y);
    }

    /**
     * Return the result of substract a vector from this vector.
     */
    public function add (other :Vector) :Vector
    {
        return new Vector(this.x + other.x, this.y + other.y);
    }

    /**
     * The dot product of two vectors.
     */
    public function dot (x :Float, y :Float) :Float
    {
        return this.x * x + this.y * y;
    }

    /**
     * Scales a vector's magnitude by a given value.
     */
    public function multiply (n :Float)
    {
        return new Vector(x * n, y * n);
    }

    /**
     * The magnitude (length) of this vector.
     */
    public function magnitude () :Float
    {
        return Math.sqrt(x*x + y*y);
    }

    /**
     * The distance between this point and another point.
     */
    public function distanceTo (x :Float, y :Float) :Float
    {
        return Math.sqrt(distanceToSquared(x, y));
    }

    /**
     * The squared distance between this point and another point. This is a faster operation than
     * distanceTo.
     */
    public function distanceToSquared (x :Float, y :Float) :Float
    {
        var dx = this.x-x;
        var dy = this.y-y;
        return dx*dx + dy*dy;
    }


    public function equals (other :Vector) :Bool
    {
        return x == other.x && y == other.y;
    }

    #if debug @:keep #end public function toString () :String
    {
        return "(" + x + "," + y + ")";
    }
}

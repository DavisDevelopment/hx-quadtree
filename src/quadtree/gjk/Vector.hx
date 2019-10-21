package quadtree.gjk;


class Vector
{
    public var x: Float;
    public var y: Float;


    public inline function new(x: Float = 0, y: Float = 0)
    {
        set(x, y);
    }


    public inline function set(x: Float, y: Float)
    {
        this.x = x;
        this.y = y;
    }


    public inline function add(v: Vector): Vector
    {
        x += v.x;
        y += v.y;
        return this;
    }


    public inline function sub(v: Vector): Vector
    {
        x -= v.x;
        y -= v.y;
        return this;
    }


    public inline function dot(x: Float, y: Float): Float
    {
        return (this.x * x) + (this.y * y);
    }


    public inline function dotVector(v: Vector): Float
    {
        return (x * v.x) + (y * v.y);
    }


    public inline function invert(): Vector
    {
        x = -x;
        y = -y;
        return this;
    }
}

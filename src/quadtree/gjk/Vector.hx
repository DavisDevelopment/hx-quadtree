package quadtree.gjk;


import quadtree.helpers.MathUtils;

class Vector
{
    public static inline var AXIS_X = 1;
    public static inline var AXIS_Y = 2;

    public var x: Float;
    public var y: Float;


    public inline function new(x: Float = 0, y: Float = 0)
    {
        set(x, y);
    }


    /** Sets the (x, y) coordinates of the vector to the given values. **/
    public inline function set(x: Float, y: Float): Vector
    {
        this.x = x;
        this.y = y;
        return this;
    }


    /** Adds the given vector to this one, and returns itself for chaining. **/
    public inline function add(v: Vector): Vector
    {
        x += v.x;
        y += v.y;
        return this;
    }


    /** Subtracts the given vector to this one, and returns itself for chaining. **/
    public inline function sub(v: Vector): Vector
    {
        x -= v.x;
        y -= v.y;
        return this;
    }


    /** Calculates and returns the dot product between this vector and the one given in (x, y) values. **/
    public inline function dot(x: Float, y: Float): Float
    {
        return (this.x * x) + (this.y * y);
    }


    /** Calculates and returns the dot product between this vector and the one given. **/
    public inline function dotVector(v: Vector): Float
    {
        return dot(v.x, v.y);
    }


    /** Multiplies the vector by the given scalar value and returns itself for chaining. **/
    public inline function mult(val: Float): Vector
    {
        x *= val;
        y *= val;
        return this;
    }


    /**
        Adds to this vector, the given vector `v` multiplied by the scalar `m`.
        Does not modify `v`. Returns itself for chaining.
    **/
    public inline function addMult(v: Vector, m: Float): Vector
    {
        x += m * v.x;
        y += m * v.y;
        return this;
    }


    /** Inverts the vector and returns itself for chaining. **/
    public inline function invert(): Vector
    {
        x = -x;
        y = -y;
        return this;
    }


    // Normalizes the vector so that its length is equal to 1 and returns itself for chaining.
    public inline function normalize(): Vector
    {
        var length: Float = getLength();
        x /= length;
        y /= length;
        return this;
    }


    /** Calculates the length of the vector. **/
    public inline function getLength(): Float
    {
        return Math.sqrt(x * x + y * y);
    }


    /** Flips the vector to its perpendicular (90-degree clockwise) and returns itself for chaining. **/
    public inline function perpendicular(): Vector
    {
        var tmp: Float = x;
        x = y;
        y = -tmp;
        return this;
    }


    /** Checks if the vector has equal coordinates with the one given. **/
    public function equals(v: Vector): Bool
    {
        return MathUtils.floatEquals(x, v.x) && MathUtils.floatEquals(y, v.y);
    }


    public function toString(): String
    {
        return '(${Math.round(x)}, ${Math.round(y)})';
    }

    #if UNIT_TEST
    public function copy(): Vector
    {
        return new VectorLinkedList(x, y);
    }
    #end
}

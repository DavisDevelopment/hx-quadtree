package quadtree.gjk;


@:forward(push, length)
abstract Simplex(Array<Vector>)
{
    // A is the last point added to the simplex.
    var A(get, never): Vector;
    // B is the penultimate in the simplex.
    var B(get, never): Vector;
    // C is the oldest point in the simplex.
    var C(get, never): Vector;
    

    public inline function new()
    {
        this = [];
    }


    public function calculateDirection(gjk: Gjk): Vector
    {
        // Since A was just added, we know that the inverse of a points towards the origin.
        var aInverted: Vector = gjk.copyVector(A).invert();


        // Check if the simplex is a triangle.
        if (this.length == 3)
        {
            // Determine A->B and A->C lines.
            var ab = gjk.copyVector(B).sub(A);
            var ac = gjk.copyVector(C).sub(A);

            // Determine perpendicular of the A->B line.
            var abPerp = gjk.recycleVector(ab.y, -ab.x);
        }


        return null;
    }


    inline function get_A(): Vector return this[this.length - 1];
    inline function get_B(): Vector return this.length == 3 ? this[1] : this[0];
    inline function get_C(): Vector return this[0];
}

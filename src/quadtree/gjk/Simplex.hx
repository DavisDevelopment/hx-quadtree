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
            // Determine the perpendicular line to A->B.
            var abPerp: Vector = gjk.copyVector(B).sub(A).perpendicular();

            // Check the direction of the perpendicular, it should
            // face AWAY from the simplex.
            if (abPerp.dotVector(C) >= 0)
            {
                abPerp.invert();
            }

            // If the origin lies outside of the simplex remove the
            // point and determine a new direction in the direction
            // of the perpendicular; aiming to try to encapsulate
            // the origin that lies outside.
            if (abPerp.dotVector(aInverted) > 0) 
            {
                removePoint(gjk, 0);
                gjk.destroyVector(aInverted);
                return abPerp;
            }
            
            gjk.destroyVector(abPerp);

            // Determine the perpendicular line to A->C.
            var acPerp: Vector = gjk.copyVector(C).sub(A).perpendicular();

             // Check the handedness of the perpendicular, it should
            // face AWAY from the simplex
            if (acPerp.dotVector(B) >= 0) 
            {
                acPerp.invert();
            }

            // If the origin lies outside of the simplex remove the
            // point and determine a new direction in the direction
            // of the perpendicular; aiming to try to encapsulate
            // the origin that lies outside
            if (acPerp.dotVector(aInverted) > 0) 
            {
                removePoint(gjk, 1);
                gjk.destroyVector(aInverted);
                return acPerp;
            }

            return null;
        }

        // Otherwise the simplex is just a line
        // B is the penultimate point in the simplex,
        // in this case the other end of the line.
        var abPerp: Vector = gjk.copyVector(B).sub(A).perpendicular();

        if (abPerp.dotVector(aInverted) <= 0)
        {
            abPerp.invert();
        }

        gjk.destroyVector(aInverted);

        return abPerp;
    }


    public inline function destroy(gjk: Gjk)
    {
        for (point in this)
        {
            gjk.destroyVector(point);
        }
    }


    inline function removePoint(gjk: Gjk, index: Int)
    {
        gjk.destroyVector(this[index]);
        this.splice(index, 1);
    }


    inline function get_A(): Vector return this[this.length - 1];
    inline function get_B(): Vector return this.length == 3 ? this[1] : this[0];
    inline function get_C(): Vector return this[0];
}

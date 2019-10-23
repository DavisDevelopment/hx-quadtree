package quadtree.extensions;

import quadtree.types.Circle;
import quadtree.gjk.Vector;


class CircleEx
{
    public static inline function getFarthestPointInDirection(c: Circle, direction: Vector, result: Vector): Vector
    {
        var center: Vector = result.set(c.centerX, c.centerY);

        return center.addMult(direction, c.radius);
    }
}

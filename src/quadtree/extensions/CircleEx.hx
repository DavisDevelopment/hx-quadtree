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


    public static inline function centerDistanceTo(c: Circle, x: Float, y: Float)
    {
        return Math.sqrt((y - c.centerY) * (y - c.centerY) + (x - c.centerX) * (x - c.centerX));
    }


    public static inline function getCenter(c: Circle, result: Vector): Vector
    {
        return result.set(c.centerX, c.centerY);
    }
}

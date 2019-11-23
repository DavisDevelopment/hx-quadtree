package quadtree.extensions;

import quadtree.types.Rectangle;
import quadtree.helpers.BoundingBox;
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


    public static inline function getBoundingBox(c: Circle, result: BoundingBox)
    {
        result.x = c.centerX - c.radius;
        result.y = c.centerY - c.radius;
        result.width = c.radius * 2;
        result.height = c.radius * 2;
    }
}

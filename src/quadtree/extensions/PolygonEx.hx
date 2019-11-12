package quadtree.extensions;

import quadtree.helpers.BoundingBox;
import quadtree.types.Rectangle;
import quadtree.gjk.Gjk;
import quadtree.types.Collider;
import quadtree.types.Polygon;
import quadtree.gjk.Vector;


class PolygonEx
{
    public static inline function getFarthestPointInDirection(p: Polygon, direction: Vector, result: Vector): Vector
    {
        var biggestDistance: Float = 0;
        var found: Bool = false;

        for (i in 0...p.points.length)
        {
            var x: Float = p.refX + p.points[i][0];
            var y: Float = p.refY + p.points[i][1];

            var distanceInDirection: Float = direction.dot(x, y);

            if (distanceInDirection > biggestDistance || !found)
            {
                result.set(x, y);
                biggestDistance = distanceInDirection;
                found = true;
            }
        }

        return found ? result : null;
    }


    public static inline function getBoundingBox(p: Polygon): Rectangle
    {
        if (p.points.length == 0)
        {
            return null;
        }

        var topLeftX: Float = p.points[0][0];
        var topLeftY: Float = p.points[0][1];
        var botRightX: Float = p.points[0][0];
        var botRightY: Float = p.points[0][1];

        for (i in 0...p.points.length)
        {
            var x: Float = p.refX + p.points[i][0];
            var y: Float = p.refY + p.points[i][1];

            if (x < topLeftX)
            {
                topLeftX = x;
            }
            if (y < topLeftY)
            {
                topLeftY = y;
            }
            if (x > botRightX)
            {
                botRightX = x;
            }
            if (y > botRightY)
            {
                botRightY = y;
            }
        }

        return new BoundingBox(topLeftX, topLeftY, botRightX - topLeftX, botRightY - topLeftY);
    }
}

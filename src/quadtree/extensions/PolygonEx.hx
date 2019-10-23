package quadtree.extensions;

import quadtree.gjk.Gjk;
import quadtree.types.Collider;
import quadtree.types.Polygon;
import quadtree.gjk.Vector;


class PolygonEx
{
    public static inline function getFarthestPointInDirection(p: Polygon, direction: Vector, result: Vector): Vector
    {
        return getFarthestPointInDirectionOfPoints(p.points, direction, result);
    }


    public static function getFarthestPointInDirectionOfPoints(points: Array<Array<Float>>, direction: Vector, result: Vector): Vector
    {
        var biggestDistance: Float = 0;
        var found: Bool = false;

        for (point in points)
        {
            var distanceInDirection: Float = direction.dot(point[0], point[1]);

            if (distanceInDirection > biggestDistance || !found)
            {
                result.set(point[0], point[1]);
                biggestDistance = distanceInDirection;
                found = true;
            }
        }

        return found ? result : null;
    }
}

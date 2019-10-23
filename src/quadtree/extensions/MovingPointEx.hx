package quadtree.extensions;

import quadtree.gjk.Gjk;
import quadtree.gjk.Vector;
import quadtree.types.Collider;
import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingPoint;
import quadtree.types.MovingRectangle;

using quadtree.extensions.MovingRectangleEx;


class MovingPointEx
{
    public static inline function intersectsWith(point: MovingPoint, other: Collider, gjk: Gjk): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: intersectsWithPoint(point, cast(other, Point));

            case CollisionAreaType.MovingPoint: intersectsWithMovingPoint(point, cast(other, MovingPoint));

            case CollisionAreaType.Rectangle: intersectsWithRectangle(point, cast(other, Rectangle));

            case _: gjk.checkOverlap(point, other);
        }
    }


    public static inline function intersectsWithPoint(point: MovingPoint, other: Point): Bool
    {
        return false;
    }


    public static inline function intersectsWithMovingPoint(point: MovingPoint, other: MovingPoint): Bool
    {
        return false;
    }


    public static inline function intersectsWithRectangle(point: MovingPoint, other: Rectangle): Bool
    {
        return PointEx.intersectsWithRectangle(point.x, point.y, other)
            || PointEx.intersectsWithRectangle(point.lastX, point.lastY, other);
    }

    
    public static inline function getFarthestPointInDirection(point: MovingPoint, direction: Vector, result: Vector): Vector
    {
        if ( direction.dot(point.x, point.y) > direction.dot(point.lastX, point.lastY) )
        {
            return result.set(point.x, point.y);
        }
        else
        {
            return result.set(point.lastX, point.lastY);
        }
    }
}

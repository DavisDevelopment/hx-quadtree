package quadtree.extensions;

import quadtree.types.Collider;
import quadtree.types.MovingPoint;
import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingRectangle;

using quadtree.extensions.MovingRectangleEx;


class PointEx
{
    public static inline function intersectsWith(point: Point, other: Collider): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: intersectsWithPoint(point, cast(other, Point));

            case CollisionAreaType.MovingPoint: intersectsWithMovingPoint(point, cast(other, MovingPoint));

            case CollisionAreaType.Rectangle: intersectsWithRectangle(point.x, point.y, cast(other, Rectangle));

            case CollisionAreaType.MovingRectangle: intersectsWithMovingRectangle(point, cast(other, MovingRectangle));

            case _: throw "Not implemented";
        }
    }


    public static inline function intersectsWithPoint(point: Point, other: Point): Bool
    {
        return false;
    }


    public static inline function intersectsWithMovingPoint(point: Point, other: MovingPoint): Bool
    {
        return false;
    }


    public static inline function intersectsWithRectangle(pointX: Float, pointY: Float, other: Rectangle): Bool
    {
        return pointX > other.x
            && pointY > other.y
            && pointX < other.x + other.width
            && pointY < other.y + other.height;
    }


    public static inline function intersectsWithMovingRectangle(point: Point, other: MovingRectangle): Bool
    {
        return MovingRectangleEx.intersectsWithPoint(other.hullX(), other.hullY(), other.hullWidth(), other.hullHeight(), point.x, point.y);
    }
}

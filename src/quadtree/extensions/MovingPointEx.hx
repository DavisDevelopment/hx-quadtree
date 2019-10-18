package quadtree.extensions;

import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingPoint;
import quadtree.types.MovingRectangle;

using quadtree.extensions.MovingRectangleEx;


class MovingPointEx
{
    public static inline function intersectsWith(point: MovingPoint, other: Point): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: intersectsWithPoint(point, other);

            case CollisionAreaType.MovingPoint: intersectsWithMovingPoint(point, other);

            case CollisionAreaType.Rectangle: intersectsWithRectangle(point, cast(other, Rectangle));

            case CollisionAreaType.MovingRectangle: intersectsWithMovingRectangle(point, cast(other, MovingRectangle));

            case _: throw "Not implemented";
        }
    }


    public static inline function intersectsWithPoint(point: MovingPoint, other: Point): Bool
    {
        return false;
    }


    public static inline function intersectsWithMovingPoint(point: MovingPoint, other: Point): Bool
    {
        return false;
    }


    public static inline function intersectsWithRectangle(point: MovingPoint, other: Rectangle): Bool
    {
        return PointEx.intersectsWithRectangle(point.x, point.y, other)
            || PointEx.intersectsWithRectangle(point.lastX, point.lastY, other);
    }


    public static inline function intersectsWithMovingRectangle(point: MovingPoint, other: MovingRectangle): Bool
    {
        return MovingRectangleEx.intersectsWithMovingPoint(other.hullX(), other.hullY(), other.hullWidth(), other.hullHeight(), point);
    }
}

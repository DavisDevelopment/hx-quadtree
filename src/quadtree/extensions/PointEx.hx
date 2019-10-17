package quadtree.extensions;

import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingRectangle;

using quadtree.extensions.MovingRectangleEx;


class PointEx
{
    public static inline function intersectsWith(point: Point, other: Point): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: intersectsWithPoint(point, other);

            case CollisionAreaType.Rectangle: intersectsWithRectangle(point, cast(other, Rectangle));

            case CollisionAreaType.MovingRectangle: intersectsWithMovingRectangle(point, cast(other, MovingRectangle));

            case _: throw "Not implemented";
        }
    }


    public static inline function intersectsWithPoint(point: Point, other: Point): Bool
    {
        return false;
    }


    public static inline function intersectsWithRectangle(point: Point, other: Rectangle): Bool
    {
        return point.x > other.x
            && point.y > other.y
            && point.x < other.x + other.width
            && point.y < other.y + other.height;
    }


    public static inline function intersectsWithMovingRectangle(point: Point, other: MovingRectangle): Bool
    {
        return MovingRectangleEx.intersectsWithPoint(other.hullX(), other.hullY(), other.hullWidth(), other.hullHeight(), point);
    }
}

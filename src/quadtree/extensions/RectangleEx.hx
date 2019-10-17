package quadtree.extensions;

import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingRectangle;

using quadtree.extensions.PointEx;
using quadtree.extensions.MovingRectangleEx;


class RectangleEx
{
    public static inline function intersectsWith(rect: Rectangle, other: Point): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: other.intersectsWithRectangle(rect);

            case CollisionAreaType.Rectangle: intersectsWithRectangle(rect, cast(other, Rectangle));

            case CollisionAreaType.MovingRectangle: intersectsWithMovingRectangle(rect, cast(other, MovingRectangle));

            case _: throw "Not implemented";
        }
    }


    public static inline function intersectsWithRectangle(rect: Rectangle, other: Rectangle): Bool
    {
        return rect.x + rect.width  > other.x
            && rect.y + rect.height > other.y
            && rect.x               < other.x + other.width
            && rect.y               < other.y + other.height;
    }


    public static inline function intersectsWithMovingRectangle(rect: Rectangle, other: MovingRectangle): Bool
    {
        return MovingRectangleEx.intersectsWithRectangle(other.hullX(), other.hullY(), other.hullWidth(), other.hullHeight(), rect);
    }
}

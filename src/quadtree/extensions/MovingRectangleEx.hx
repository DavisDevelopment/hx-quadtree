package quadtree.extensions;

import quadtree.helpers.BoundingBox;
import quadtree.gjk.Gjk;
import quadtree.gjk.Vector;
import quadtree.types.Collider;
import quadtree.types.MovingPoint;
import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingRectangle;

using quadtree.extensions.MovingRectangleEx;
using quadtree.helpers.MathUtils;


class MovingRectangleEx
{
    public static inline function intersectsWith(rect: MovingRectangle, hullX: Float, hullY: Float, hullWidth: Float, hullHeight: Float, other: Collider, gjk: Gjk): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: 
                intersectsWithPoint(hullX, hullY, hullWidth, hullHeight, rect.angle, cast(other, Point).x, cast(other, Point).y);

            case CollisionAreaType.Rectangle if (rect.angle.isZero() && cast(other, Rectangle).angle.isZero()):
                intersectsWithRectangle(hullX, hullY, hullWidth, hullHeight, cast(other, Rectangle));

            case CollisionAreaType.MovingRectangle if (rect.angle.isZero() && cast(other, MovingRectangle).angle.isZero()):
                intersectsWithMovingRectangle(hullX, hullY, hullWidth, hullHeight, cast(other, MovingRectangle));

            case _: gjk.checkOverlap(rect, other);
        }
    }


    public static inline function intersectsWithPoint(hullX: Float, hullY: Float, hullWidth: Float, hullHeight: Float, angle:Float, pointX: Float, pointY: Float): Bool
    {
        return PointEx.intersectsWithRectangle(pointX, pointY, hullX, hullY, hullWidth, hullHeight, angle);
    }


    public static inline function intersectsWithRectangle(hullX: Float, hullY: Float, hullWidth: Float, hullHeight: Float, other: Rectangle): Bool
    {
        return hullX + hullWidth  > other.x
            && hullY + hullHeight > other.y
            && hullX              < other.x + other.width
            && hullY              < other.y + other.height;
    }


    public static inline function intersectsWithMovingRectangle(hullX: Float, hullY: Float, hullWidth: Float, hullHeight: Float, other: MovingRectangle): Bool
    {
        return hullX + hullWidth  > other.hullX()
            && hullY + hullHeight > other.hullY()
            && hullX              < other.hullX() + other.hullWidth()
            && hullY              < other.hullY() + other.hullHeight();
    }

    
    public static inline function getFarthestPointInDirection(rect: MovingRectangle, direction: Vector, result: Vector): Vector
    {
        return RectangleEx.getFarthestPointInDirectionRect(rect.hullX(), rect.hullY(), rect.hullWidth(), rect.hullHeight(), rect.angle, direction, result);
    }


    public static inline function hullX(rect: MovingRectangle): Float
    {
        return Math.min(rect.x, rect.lastX);
    }
    

    public static inline function hullY(rect: MovingRectangle): Float
    {
        return Math.min(rect.y, rect.lastY);
    }
    

    public static inline function hullWidth(rect: MovingRectangle): Float
    {
        return rect.width + Math.abs(rect.x - rect.lastX);
    }
    

    public static inline function hullHeight(rect: MovingRectangle): Float
    {
        return rect.height + Math.abs(rect.y - rect.lastY);
    }


    public static inline function getBoundingBox(r: MovingRectangle, result: BoundingBox)
    {
        result.x = r.hullX();
        result.y = r.hullY();
        result.width = r.hullWidth();
        result.height = r.hullHeight();
    }
}

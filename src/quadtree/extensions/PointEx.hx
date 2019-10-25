package quadtree.extensions;

import quadtree.gjk.Gjk;
import quadtree.gjk.Vector;
import quadtree.types.Collider;
import quadtree.types.MovingPoint;
import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingRectangle;

using quadtree.helpers.MathUtils;
using quadtree.extensions.MovingRectangleEx;


class PointEx
{
    public static inline function intersectsWith(point: Point, other: Collider, gjk: Gjk): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: intersectsWithPoint(point, cast(other, Point));

            case CollisionAreaType.MovingPoint: intersectsWithMovingPoint(point, cast(other, MovingPoint));

            case CollisionAreaType.Rectangle: intersectsWithRectangle(point.x, point.y, cast(other, Rectangle));

            case CollisionAreaType.MovingRectangle: intersectsWithMovingRectangle(point, cast(other, MovingRectangle));

            case _: gjk.checkOverlap(point, other);
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


    public static function intersectsWithRectangle(pointX: Float, pointY: Float, other: Rectangle): Bool
    {
        if (!other.angle.isZero())
        {
            var cos: Float = MathUtils.fastCos(-other.angle);
            var sin: Float = MathUtils.fastSin(-other.angle);
            var rectCenterX: Float = other.x + (other.width / 2);
            var rectCenterY: Float = other.y + (other.height / 2);

            var rotatedX: Float = MathUtils.rotateX(cos, sin, pointX, pointY, rectCenterX, rectCenterY);
            var rotatedY: Float = MathUtils.rotateY(cos, sin, pointX, pointY, rectCenterX, rectCenterY);

            pointX = rotatedX;
            pointY = rotatedY;
        }        

        return pointX > other.x
            && pointY > other.y
            && pointX < other.x + other.width
            && pointY < other.y + other.height;
    }


    public static inline function intersectsWithMovingRectangle(point: Point, other: MovingRectangle): Bool
    {
        return MovingRectangleEx.intersectsWithPoint(other.hullX(), other.hullY(), other.hullWidth(), other.hullHeight(), other.angle, point.x, point.y);
    }

    
    public static inline function getFarthestPointInDirection(point: Point, direction: Vector, result: Vector): Vector
    {
        return result.set(point.x, point.y);
    }
}

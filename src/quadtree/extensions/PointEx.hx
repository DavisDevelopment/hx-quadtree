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

            case CollisionAreaType.Rectangle: intersectsWithRectangle(point.x, point.y, cast(other, Rectangle).x, cast(other, Rectangle).y, cast(other, Rectangle).width, cast(other, Rectangle).height, cast(other, Rectangle).angle);

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


    public static function intersectsWithRectangle(pointX: Float, pointY: Float, x: Float, y: Float, width: Float, height: Float, angle: Float): Bool
    {
        if (!angle.isZero())
        {
            var cos: Float = MathUtils.fastCos(-angle);
            var sin: Float = MathUtils.fastSin(-angle);
            var rectCenterX: Float = x + (width / 2);
            var rectCenterY: Float = y + (height / 2);

            var rotatedX: Float = MathUtils.rotateX(cos, sin, pointX, pointY, rectCenterX, rectCenterY);
            var rotatedY: Float = MathUtils.rotateY(cos, sin, pointX, pointY, rectCenterX, rectCenterY);

            pointX = rotatedX;
            pointY = rotatedY;
        }        

        return pointX >= x
            && pointY >= y
            && pointX < x + width
            && pointY < y + height;
    }


    public static inline function intersectsWithMovingRectangle(point: Point, other: MovingRectangle): Bool
    {
        return intersectsWithRectangle(point.x, point.y, other.hullX(), other.hullY(), other.hullWidth(), other.hullHeight(), other.angle);
    }

    
    public static inline function getFarthestPointInDirection(point: Point, direction: Vector, result: Vector): Vector
    {
        return result.set(point.x, point.y);
    }
}

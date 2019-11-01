package quadtree.extensions;

import quadtree.gjk.Gjk;
import quadtree.gjk.Vector;
import quadtree.types.Collider;
import quadtree.types.MovingPoint;
import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingRectangle;

using quadtree.helpers.MathUtils;
using quadtree.extensions.PointEx;
using quadtree.extensions.MovingPointEx;
using quadtree.extensions.MovingRectangleEx;


class RectangleEx
{
    public static inline function intersectsWith(rect: Rectangle, other: Collider, gjk: Gjk): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: 
                intersectsWithPoint(rect, cast(other, Point));

            case CollisionAreaType.MovingPoint: 
                intersectsWithMovingPoint(rect, cast(other, MovingPoint));

            case CollisionAreaType.Rectangle if (rect.angle.isZero() && cast(other, Rectangle).angle.isZero()):
                intersectsWithRectangle(rect, cast(other, Rectangle));

            case CollisionAreaType.MovingRectangle if (rect.angle.isZero() && cast(other, MovingRectangle).angle.isZero()):
                intersectsWithMovingRectangle(rect, cast(other, MovingRectangle));

            case _: gjk.checkOverlap(rect, other);
        }
    }


    public static inline function intersectsWithPoint(rect: Rectangle, other: Point): Bool
    {
        return PointEx.intersectsWithRectangle(other.x, other.y, rect.x, rect.y, rect.width, rect.height, rect.angle);
    }


    public static inline function intersectsWithMovingPoint(rect: Rectangle, other: MovingPoint): Bool
    {
        return cast(other, MovingPoint).intersectsWithRectangle(rect);
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

    
    public static inline function getFarthestPointInDirection(rect: Rectangle, direction: Vector, result: Vector): Vector
    {
        return getFarthestPointInDirectionRect(rect.x, rect.y, rect.width, rect.height, rect.angle, direction, result);
    }

    
    public static function getFarthestPointInDirectionRect(x: Float, y: Float, width: Float, height: Float, angle: Float, direction: Vector, result: Vector): Vector
    {
        if (angle.isZero())
        {
            var distanceToTopLeft: Float = direction.dot(x, y);
            var distanceToTopRight: Float  = direction.dot(x + width, y);
            var distanceToBotLeft: Float = direction.dot(x, y + height);
            var distanceToBotRight: Float  = direction.dot(x + width, y + height);

            if (distanceToTopLeft > distanceToTopRight && distanceToTopLeft > distanceToBotLeft && distanceToTopLeft > distanceToBotRight)
            {
                // top left
                result.set(x, y);
            }
            else if (distanceToTopRight > distanceToBotLeft && distanceToTopRight > distanceToBotRight)
            {
                // top right
                result.set(x + width, y);
            }
            else if (distanceToBotLeft > distanceToBotRight)
            {
                // bot left
                result.set(x, y + height);
            }
            else
            {
                // bot right
                result.set(x + width, y + height);
            }
        }
        else
        {
            var centerX: Float = x + (width / 2);
            var centerY: Float = y + (height / 2);
            var cos: Float = MathUtils.fastCos(angle);
            var sin: Float = MathUtils.fastSin(angle);

            var x0: Float = MathUtils.rotateX(cos, sin, x,         y,          centerX, centerY);
            var y0: Float = MathUtils.rotateY(cos, sin, x,         y,          centerX, centerY);
            var x1: Float = MathUtils.rotateX(cos, sin, x + width, y,          centerX, centerY);
            var y1: Float = MathUtils.rotateY(cos, sin, x + width, y,          centerX, centerY);
            var x2: Float = MathUtils.rotateX(cos, sin, x,         y + height, centerX, centerY);
            var y2: Float = MathUtils.rotateY(cos, sin, x,         y + height, centerX, centerY);
            var x3: Float = MathUtils.rotateX(cos, sin, x + width, y + height, centerX, centerY);
            var y3: Float = MathUtils.rotateY(cos, sin, x + width, y + height, centerX, centerY);
            
            var distanceToTopLeft: Float  = direction.dot(x0, y0);
            var distanceToTopRight: Float = direction.dot(x1, y1);
            var distanceToBotLeft: Float  = direction.dot(x2, y2);
            var distanceToBotRight: Float = direction.dot(x3, y3);

            if (distanceToTopLeft > distanceToTopRight && distanceToTopLeft > distanceToBotLeft && distanceToTopLeft > distanceToBotRight)
            {
                // top left
                result.set(x0, y0);
            }
            else if (distanceToTopRight > distanceToBotLeft && distanceToTopRight > distanceToBotRight)
            {
                // top right
                result.set(x1, y1);
            }
            else if (distanceToBotLeft > distanceToBotRight)
            {
                // bot left
                result.set(x2, y2);
            }
            else
            {
                // bot right
                result.set(x3, y3);
            }
        }

        return result;
    }
}

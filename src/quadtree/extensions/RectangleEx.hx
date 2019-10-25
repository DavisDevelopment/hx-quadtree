package quadtree.extensions;

import quadtree.helpers.MathUtils;
import quadtree.gjk.Gjk;
import quadtree.gjk.Vector;
import quadtree.types.Collider;
import quadtree.types.MovingPoint;
import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingRectangle;

using quadtree.extensions.PointEx;
using quadtree.extensions.MovingPointEx;
using quadtree.extensions.MovingRectangleEx;


class RectangleEx
{
    public static inline function intersectsWith(rect: Rectangle, other: Collider, gjk: Gjk): Bool
    {
        return switch other.areaType
        {
            case CollisionAreaType.Point: intersectsWithPoint(rect, cast(other, Point));

            case CollisionAreaType.MovingPoint: intersectsWithMovingPoint(rect, cast(other, MovingPoint));

            case CollisionAreaType.Rectangle: intersectsWithRectangle(rect, cast(other, Rectangle));

            case CollisionAreaType.MovingRectangle: intersectsWithMovingRectangle(rect, cast(other, MovingRectangle));

            case _: gjk.checkOverlap(rect, other);
        }
    }


    public static inline function intersectsWithPoint(rect: Rectangle, other: Point): Bool
    {
        return PointEx.intersectsWithRectangle(other.x, other.y, rect);
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
        if (angle == 0)
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
            
            var distanceToTopLeft: Float = rotatedDot(direction, cos, sin, x, y, centerX, centerY);
            var distanceToTopRight: Float = rotatedDot(direction, cos, sin, x + width, y, centerX, centerY);
            var distanceToBotLeft: Float = rotatedDot(direction, cos, sin, x, y + height, centerX, centerY);
            var distanceToBotRight: Float = rotatedDot(direction, cos, sin, x + width, y + height, centerX, centerY);

            if (distanceToTopLeft > distanceToTopRight && distanceToTopLeft > distanceToBotLeft && distanceToTopLeft > distanceToBotRight)
            {
                // top left
                result.set( rotateX(cos, sin, x, y, centerX, centerY) , rotateY(cos, sin, x, y, centerX, centerY) );
            }
            else if (distanceToTopRight > distanceToBotLeft && distanceToTopRight > distanceToBotRight)
            {
                // top right
                result.set( rotateX(cos, sin, x + width, y, centerX, centerY) , rotateY(cos, sin, x + width, y, centerX, centerY) );
            }
            else if (distanceToBotLeft > distanceToBotRight)
            {
                // bot left
                result.set( rotateX(cos, sin,x, y + height, centerX, centerY) , rotateY(cos, sin, x, y + height, centerX, centerY) );
            }
            else
            {
                // bot right
                result.set( rotateX(cos, sin, x + width, y + height, centerX, centerY) , rotateY(cos, sin, x + width, y + height, centerX, centerY) );
            }
        }

        return result;
    }


    static inline function rotatedDot(v: Vector, cos: Float, sin: Float, x: Float, y: Float, x0: Float, y0: Float)
    {
        return v.dot( rotateX(cos, sin, x, y, x0, y0) , rotateY(cos, sin, x, y, x0, y0) );
    }


    static inline function rotateX(cos: Float, sin: Float, x: Float, y: Float, x0: Float, y0: Float): Float
    {
        return x0 + (x - x0)*cos - (y - y0)*sin;
    }


    static inline function rotateY(cos: Float, sin: Float, x: Float, y: Float, x0: Float, y0: Float): Float
    {
        return y0 + (x - x0)*sin + (y - y0)*cos;
    }
}

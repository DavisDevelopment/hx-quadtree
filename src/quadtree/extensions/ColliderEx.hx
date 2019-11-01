package quadtree.extensions;

import quadtree.gjk.Vector.AXIS_X;
import quadtree.gjk.Vector.AXIS_Y;
import quadtree.types.Collider;
import quadtree.types.Rectangle;
import quadtree.types.MovingPoint;
import quadtree.types.MovingRectangle;

using quadtree.helpers.MathUtils;


class ColliderEx
{
    public static inline function getObjectDelta(obj: Collider, axis: Int): Float
    {
        return switch [obj.areaType, axis]
        {
            case [MovingRectangle, AXIS_X]: cast(obj, MovingRectangle).x - cast(obj, MovingRectangle).lastX;
            case [MovingRectangle, AXIS_Y]: cast(obj, MovingRectangle).y - cast(obj, MovingRectangle).lastY;
            
            case [MovingPoint, AXIS_X]: cast(obj, MovingPoint).x - cast(obj, MovingPoint).lastX;
            case [MovingPoint, AXIS_Y]: cast(obj, MovingPoint).y - cast(obj, MovingPoint).lastY;

            case _: 0;
        }
    }


    public static inline function isAlignedRectangle(obj: Collider): Bool
    {
        return obj.areaType & (CollisionAreaType.Rectangle | CollisionAreaType.MovingRectangle) > 0
            && cast(obj, Rectangle).angle.isZero();
    }


    public static inline function isCircle(obj: Collider): Bool
    {
        return obj.areaType & (CollisionAreaType.Circle | CollisionAreaType.MovingCircle) > 0;
    }


    public static inline function isMovableType(obj: Collider): Bool
    {
        return obj.areaType & (CollisionAreaType.MovingPoint | CollisionAreaType.MovingRectangle | CollisionAreaType.MovingCircle | CollisionAreaType.MovingPolygon) > 0;
    }
}

package quadtree;

import quadtree.types.Rectangle;
import quadtree.helpers.Overlap;
import quadtree.types.Circle;
import tests.models.MovingPoint;
import quadtree.types.MovingRectangle;
import quadtree.types.Collider;
import quadtree.gjk.Vector;
import quadtree.gjk.Vector.AXIS_X;
import quadtree.gjk.Vector.AXIS_Y;

using quadtree.Physics;
using quadtree.extensions.CircleEx;
using quadtree.helpers.MathUtils;


class Physics
{
    public static function separate(obj1: Collider, obj2: Collider, obj1Immovable: Bool = false, obj2Immovable: Bool = false): Float
    {
        var overlapX: Float = computeOverlap(obj1, obj2, AXIS_X);
        var overlapY: Float = computeOverlap(obj1, obj2, AXIS_Y);

        if (obj2Immovable || !obj2.isMovableType())
        {
            obj1.moveToSeparate(-overlapX, -overlapY);
        }
        else if (obj1Immovable || !obj1.isMovableType())
        {
            obj2.moveToSeparate(overlapX, overlapY);
        }
        else
        {
            obj1.moveToSeparate(-overlapX / 2, -overlapY / 2);
            obj2.moveToSeparate( overlapX / 2,  overlapY / 2);
        }

        return Math.atan2(overlapY, overlapX);
    }


    /**
        Performs a momentum conservation collision on the two given velocity vectors, 
        updating them to their new post-collision velocities.

        @param velocity1 The velocity vector of the first object.
        @param velocity2 The velocity vector of the second object.
        @param angleCos The cosine of the angle on which the two objects are being separated.
        @param angleSin The sine of the angle on which the two objects are being separated.
        @param mass1 The mass of the first object.
        @param mass2 The mass of the second object.
        @param elasticity1 The elasticity of the first object.
        @param elasticity2 The elasticity of the second object.

    **/
    public static function momentumConservationCollision(
        velocity1: Vector, velocity2: Vector, 
        angleCos: Float, angleSin: Float, 
        mass1: Float = 1, mass2: Float = 1,
        elasticity1: Float = 1, elasticity2: Float = 1)
    {
        var vel1x: Float = momentumConservationVelocity(velocity1.x, velocity2.x, mass1, mass2);
        var vel1y: Float = momentumConservationVelocity(velocity1.y, velocity2.y, mass1, mass2);

        var vel2x: Float = momentumConservationVelocity(velocity2.x, velocity1.x, mass2, mass1);
        var vel2y: Float = momentumConservationVelocity(velocity2.y, velocity1.y, mass2, mass1);

        var vel1: Float = elasticity1 * Math.sqrt(vel1x * vel1x + vel1y * vel1y);
        velocity1.x = - vel1 * angleCos;
        velocity1.y = - vel1 * angleSin;

        var vel2: Float = elasticity2 * Math.sqrt(vel2x * vel2x + vel2y * vel2y);
        velocity2.x = vel2 * angleCos;
        velocity2.y = vel2 * angleSin;
    }


    /**
        Calculates the scalar post-collision velocity of an object.
        Mean to be calculated for each axis separately.

        @param mass The mass of the object.
        @param velocity The velocity of the object on the respective axis.
        @param otherMass The mass of the other object.
        @param otherVelocity The velocity of the other object on the respective axis.
        @return The new velocity of the object on the respective axis after the collision.
    **/
    static inline function momentumConservationVelocity(velocity: Float, otherVelocity: Float, mass: Float = 1, otherMass: Float = 1): Float
    {
        return ( (mass - otherMass) * velocity + (2 * otherMass * otherVelocity) ) / (mass + otherMass);
    }


    /**
        Computes the overlap of two given objects on the given axis.
        This function assumes that the objects are moveable and bases the overlap on
        their last movement.

        This overlap should be subtracted from `obj1` and added to `obj2`.
    **/
    static function computeOverlap(obj1: Collider, obj2: Collider, axis: Int): Float
    {
        // Check if both are circles.
        if (obj1.isCircle() && obj2.isCircle())
        {
            return Overlap.circleInCircle(cast obj1, cast obj2, axis);
        }

        // Calculate overlap based on movement.
        var delta1: Float = getObjectDelta(obj1, axis);
        var delta2: Float = getObjectDelta(obj2, axis);
        var delta: Float = delta1 - delta2;

        // Check if one is a circle and the other a rectangle.
        if (obj1.isCircle() && obj2.isAlignedRectangle())
        {
            return Overlap.circleInAlignedRectangle(cast obj1, cast obj2, axis, delta);
        }
        if (obj1.isAlignedRectangle() && obj2.isCircle())
        {
            return -Overlap.circleInAlignedRectangle(cast obj2, cast obj1, axis, -delta);
        }

        // Check if both are rectangles.
        if (obj1.isAlignedRectangle() && obj2.isAlignedRectangle())
        {
            return Overlap.alignedRectangleInAlignedRectangle(cast obj1, cast obj2, axis, delta);
        }

        return delta;
    }


    static inline function getObjectDelta(obj: Collider, axis: Int): Float
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


    static inline function isAlignedRectangle(obj: Collider): Bool
    {
        return obj.areaType & (CollisionAreaType.Rectangle | CollisionAreaType.MovingRectangle) > 0
            && cast(obj, Rectangle).angle.isZero();
    }


    static inline function isCircle(obj: Collider): Bool
    {
        return obj.areaType & (CollisionAreaType.Circle | CollisionAreaType.MovingCircle) > 0;
    }


    static inline function isMovableType(obj: Collider): Bool
    {
        return obj.areaType & (CollisionAreaType.MovingPoint | CollisionAreaType.MovingRectangle | CollisionAreaType.MovingCircle | CollisionAreaType.MovingPolygon) > 0;
    }
}

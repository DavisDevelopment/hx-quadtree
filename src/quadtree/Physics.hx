package quadtree;

import quadtree.helpers.CollisionResult;
import quadtree.types.Rectangle;
import quadtree.helpers.Overlap;
import quadtree.types.Circle;
import quadtree.types.MovingRectangle;
import quadtree.types.MovingPoint;
import quadtree.types.Collider;
import quadtree.gjk.Vector;
import quadtree.gjk.Vector.AXIS_X;
import quadtree.gjk.Vector.AXIS_Y;

using quadtree.extensions.ColliderEx;
using quadtree.extensions.CircleEx;
using quadtree.helpers.MathUtils;


class Physics
{
    /**
        Separates the two given overlapping objects, based on their movement.

        @param collisionResult The collision result. This object will be modified in-place to contain information about the separation.
    **/
    public static function separate(collisionResult: CollisionResult)
    {
        final obj1: Collider = collisionResult.object1;
        final obj2: Collider = collisionResult.object2;

        final obj1canMove: Bool = collisionResult.canObject1Move();
        final obj2canMove: Bool = collisionResult.canObject2Move();

        var overlapX: Float = computeOverlap(obj1, obj2, AXIS_X);
        var overlapY: Float = computeOverlap(obj1, obj2, AXIS_Y);

        if (!overlapX.isZero() && !overlapY.isZero())
        {
            // We have overlap on both axes.
            // Check if we can ignore one of them and settle for a small
            // correction on the other.
            // (for example when touching the ground, you only want to correct upwards)

            if (!overlapX.isZero() && Math.abs(overlapX / overlapY) < 0.3)
            {
                // Significantly smaller margin on the x-axis, use only that for separation.
                overlapY = 0;
            }
            else if (!overlapY.isZero() && Math.abs(overlapY / overlapX) < 0.3)
            {
                // Significantly smaller margin on the y-axis, use only that for separation.
                overlapX = 0;
            }
        }


        var separationHappened: Bool = false;

        if (overlapX.isZero() && overlapY.isZero())
        {
            // No overlap, do nothing.
        }
        else if (obj1canMove && obj2canMove)
        {
            obj1.moveToSeparate(-overlapX / 2, -overlapY / 2);
            obj2.moveToSeparate( overlapX / 2,  overlapY / 2);
            separationHappened = true;
        }
        else if (!obj2canMove)
        {
            obj1.moveToSeparate(-overlapX, -overlapY);
            separationHappened = true;
        }
        else if (!obj1canMove)
        {
            obj2.moveToSeparate(overlapX, overlapY);
            separationHappened = true;
        }

        collisionResult.setSeparation(overlapX, overlapY, separationHappened, Math.atan2(overlapY, overlapX));
    }


    /**
        Performs a momentum conservation collision on the two given velocity vectors in the given collision result,
        updating them to their new post-collision velocities.

        @param collisionResult The collision result. The velocities in this object will be updated in-place to their new post-collision values.
        @return Returns `false` if both objects are immovable, and velocities weren't updated.

    **/
    public static function momentumConservationCollision(collisionResult: CollisionResult): Bool
    {
        final velocity1: Vector = collisionResult.obj1Velocity;
        final mass1: Float = collisionResult.obj1Mass;
        final elasticity1: Float = collisionResult.obj1Elasticity;
        final canMove1: Bool = collisionResult.canObject1Move();

        final velocity2: Vector = collisionResult.obj2Velocity;
        final mass2: Float = collisionResult.obj2Mass;
        final elasticity2: Float = collisionResult.obj2Elasticity;
        final canMove2: Bool = collisionResult.canObject2Move();

        final overlapX: Float = collisionResult.overlapX;
        final overlapY: Float = collisionResult.overlapY;
        final separationAngle: Float = collisionResult.separationAngle;

        if (!canMove1 && !canMove2)
        {
            // Both objects are immovable.
            return false;
        }

        if (canMove1 && canMove2)
        {
            // First compute their new velocities by computing moment conservation on each axis separately.
            var vel1x: Float = momentumConservationVelocity(velocity1.x, velocity2.x, mass1, mass2);
            var vel1y: Float = momentumConservationVelocity(velocity1.y, velocity2.y, mass1, mass2);

            var vel2y: Float = momentumConservationVelocity(velocity2.y, velocity1.y, mass2, mass1);
            var vel2x: Float = momentumConservationVelocity(velocity2.x, velocity1.x, mass2, mass1);

            if (overlapX.isZero())
            {
                // Bounce only on the y-axis.
                velocity1.y = elasticity1 * vel1y;
                velocity2.y = elasticity2 * vel2y;
            }
            else if (overlapY.isZero())
            {
                // Bounce only on the x-axis.
                velocity1.x = elasticity1 * vel1x;
                velocity2.x = elasticity2 * vel2x;
            }
            else
            {
                var angleCos: Float = MathUtils.fastCos(separationAngle);
                var angleSin: Float = MathUtils.fastSin(separationAngle);

                var velocity1Scalar: Float = elasticity1 * Math.sqrt(vel1x * vel1x + vel1y * vel1y);
                var velocity2Scalar: Float = elasticity2 * Math.sqrt(vel2x * vel2x + vel2y * vel2y);

                velocity1.x = - velocity1Scalar * angleCos;
                velocity1.y = - velocity1Scalar * angleSin;

                velocity2.x = velocity2Scalar * angleCos;
                velocity2.y = velocity2Scalar * angleSin;
            }

        }
        else if (!canMove2)
        {
            computeBounce(velocity1, Math.PI + separationAngle, elasticity1, overlapX, overlapY);
        }
        else if (!canMove1)
        {
            computeBounce(velocity2, separationAngle, elasticity2, overlapX, overlapY);
        }


        return true;
    }


    static function computeBounce(velocity: Vector, angle: Float, elasticity: Float, overlapX: Float, overlapY: Float)
    {
        if (overlapX.isZero())
        {
            // Bounce only on the y-axis.
            velocity.y = - elasticity * velocity.y;
        }
        else if (overlapY.isZero())
        {
            // Bounce only on the x-axis.
            velocity.x = - elasticity * velocity.x;
        }
        else
        {
            var scalarVelocity: Float = elasticity * velocity.getLength();

            velocity.x = scalarVelocity * MathUtils.fastCos(angle);
            velocity.y = scalarVelocity * MathUtils.fastSin(angle);
        }
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
        var delta1: Float = obj1.getObjectDelta(axis);
        var delta2: Float = obj2.getObjectDelta(axis);
        var delta: Float = delta1 - delta2;
        var overlap: Float = delta;

        // Check if one is a circle and the other a rectangle.
        if (obj1.isCircle() && obj2.isAlignedRectangle())
        {
            overlap = Overlap.circleInAlignedRectangle(cast obj1, cast obj2, axis, delta);
        }
        if (obj1.isAlignedRectangle() && obj2.isCircle())
        {
            overlap = -Overlap.circleInAlignedRectangle(cast obj2, cast obj1, axis, -delta);
        }

        // Check if both are rectangles.
        if (obj1.isAlignedRectangle() && obj2.isAlignedRectangle())
        {
            overlap = Overlap.alignedRectangleInAlignedRectangle(cast obj1, cast obj2, axis, delta);
        }
        
        return overlap >= 1 ? overlap : 0;
    }
}

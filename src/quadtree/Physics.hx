package quadtree;

import quadtree.gjk.Vector;


class Physics
{
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
    public static inline function momentumConservationVelocity(velocity: Float, otherVelocity: Float, mass: Float = 1, otherMass: Float = 1): Float
    {
        return ( (mass - otherMass) * velocity + 2 * otherMass * otherVelocity ) / (mass + otherMass);
    }
}

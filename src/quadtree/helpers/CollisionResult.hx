package quadtree.helpers;

import quadtree.gjk.Vector;
import quadtree.types.Collider;

using quadtree.extensions.ColliderEx;


/**
    Helper class used to store information about the collision of two objects,
    as well as their separation and velocity calculations.
**/
class CollisionResult
{
    /** The first colliding object. **/
    public var object1(default, null): Collider;
    /** The second colliding object. **/
    public var object2(default, null): Collider;

    /** The overlap of the two objects on the x-axis. Updated by Physics.separate(). **/
    public var overlapX(default, null): Float;
    /** The overlap of the two objects on the y-axis. Updated by Physics.separate(). **/
    public var overlapY(default, null): Float;
    /** Whether or not separation happened during the call to Physics.separate(). **/
    public var separationHappened(default, null): Bool;
    /** The angle by which the two objects were separated. Updated by Physics.separate().**/
    public var separationAngle(default, null): Float;

    /** The velocity of the first object. Update by calling set() on it. **/
    public var obj1Velocity(default, null): Vector;
    /** The mass of the first object. Default is `1`.**/
    public var obj1Mass: Float;
    /** The elasticity of the first object. Default is `1`.**/
    public var obj1Elasticity: Float;
    /** Whether the first object is immovable. Default is `false`. **/
    public var obj1Immovable: Bool;

    /** The velocity of the second object. Update by calling set() on it. **/
    public var obj2Velocity(default, null): Vector;
    /** The mass of the second object. Default is `1`.**/
    public var obj2Mass: Float;
    /** The elasticity of the second object. Default is `1`.**/
    public var obj2Elasticity: Float;
    /** Whether the second object is immovable. Default is `false`. **/
    public var obj2Immovable: Bool;


    public inline function new(?object1: Collider, ?object2: Collider)
    {
        obj1Velocity = new Vector();
        obj2Velocity = new Vector();
        set(object1, object2);
    }


    @:allow(quadtree.QuadTree)
    function set(object1: Collider, object2: Collider)
    {
        this.object1 = object1;
        obj1Velocity.set(0, 0);
        obj1Mass = 1;
        obj1Elasticity = 1;
        obj1Immovable = false;
        this.object2 = object2;
        obj2Velocity.set(0, 0);
        obj2Mass = 1;
        obj2Elasticity = 1;
        obj2Immovable = false;

        overlapX = 0;
        overlapY = 0;
        separationHappened = false;
        separationAngle = 0;
    }


    @:allow(quadtree.Physics)
    function setSeparation(overlapX: Float, overlapY: Float, separationHappened: Bool, separationAngle: Float = 0)
    {
        this.overlapX = overlapX;
        this.overlapY = overlapY;
        this.separationHappened = separationHappened;
        this.separationAngle = separationAngle;
    }


    public inline function canObject1Move(): Bool
    {
        return object1 != null && !obj1Immovable && object1.isMovableType();
    }


    public inline function canObject2Move(): Bool
    {
        return object2 != null && !obj2Immovable && object2.isMovableType();
    }
}

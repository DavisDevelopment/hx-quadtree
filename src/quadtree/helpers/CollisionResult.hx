package quadtree.helpers;

import quadtree.types.Rectangle;
import quadtree.gjk.Vector;
import quadtree.types.Collider;

using quadtree.helpers.MathUtils;
using quadtree.extensions.ColliderEx;
using quadtree.extensions.RectangleEx;


@:enum
abstract ObjectId(Int)
{
    var Object1 = 1;
    var Object2 = 2;
}


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

    /** The velocity of the first object. Update by calling set() on it. **/
    public var obj1Velocity(default, null): Vector;
    /** The mass of the first object. Default is `1`.**/
    public var obj1Mass: Float;
    /** The elasticity of the first object. Default is `0`.**/
    public var obj1Elasticity: Float;
    /** Whether the first object is immovable. Default is `false`. **/
    public var obj1Immovable: Bool;

    /** The velocity of the second object. Update by calling set() on it. **/
    public var obj2Velocity(default, null): Vector;
    /** The mass of the second object. Default is `1`.**/
    public var obj2Mass: Float;
    /** The elasticity of the second object. Default is `0`.**/
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
        obj1Elasticity = 0;
        obj1Immovable = false;
        this.object2 = object2;
        obj2Velocity.set(0, 0);
        obj2Mass = 1;
        obj2Elasticity = 0;
        obj2Immovable = false;

        overlapX = 0;
        overlapY = 0;
        separationHappened = false;
    }


    public inline function canObject1Move(): Bool
    {
        return object1 != null && !obj1Immovable && object1.isMovableType();
    }


    public inline function canObject2Move(): Bool
    {
        return object2 != null && !obj2Immovable && object2.isMovableType();
    }


    public inline function wereOverlapping(): Bool
    {
        return !overlapX.isZero() || !overlapY.isZero();
    }


    /**
        The angle by which the two objects were separated. Updated by Physics.separate().
    **/
    public inline function separationAngle(): Float
    {
        return MathUtils.fastAtan2(overlapY, overlapX);
    }


    /**
        Computes and returns the Minkowski difference of `to - from`.
    **/
    public function computeMinkowskiDifference(): Rectangle
    {
        var from: Rectangle = boundBox1_;
        var fromExists: Bool = object2.getBoundingBox(boundBox1_);
        var to: Rectangle = boundBox2_;
        var toExists: Bool = object1.getBoundingBox(boundBox2_);

        if (!fromExists || !toExists || !from.intersectsWithRectangle(to))
        {
            return null;
        }

        minkowskiDifference_.x = to.x - (to.width / 2) - from.x - from.width;
        minkowskiDifference_.y = to.y - (to.height / 2) - from.y - from.height;
        minkowskiDifference_.width = to.width + from.width;
        minkowskiDifference_.height = to.height + from.height;

        return minkowskiDifference_;
    }


    @:allow(quadtree.Physics)
    @:allow(quadtree.extensions.RectangleEx)
    inline function addOverlap(overlapX: Float, overlapY: Float)
    {
        this.overlapX = MathUtils.maxAbs(this.overlapX, overlapX);
        this.overlapY = MathUtils.maxAbs(this.overlapY, overlapY);
    }


    @:allow(quadtree.Physics)
    inline function addSeparation(overlapX: Float, overlapY: Float, separationHappened: Bool)
    {
        addOverlap(overlapX, overlapY);
        this.separationHappened = this.separationHappened || separationHappened;
    }


    @:allow(quadtree.Physics)
    inline function setObjects(obj1: Collider, obj2: Collider)
    {
        object1 = obj1;
        object2 = obj2;
    }


    /**
        CACHED OBJECTS
    **/
    @:noCompletion var boundBox1_: BoundingBox = new BoundingBox(0, 0);
    @:noCompletion var boundBox2_: BoundingBox = new BoundingBox(0, 0);
    @:noCompletion var minkowskiDifference_: BoundingBox = new BoundingBox(0, 0);
}

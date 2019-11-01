package quadtree.helpers;

import quadtree.types.Collider;


class CollisionResult
{
    public var object1(default, null): Collider;
    public var object2(default, null): Collider;

    public var overlapX(default, null): Float;
    public var overlapY(default, null): Float;
    public var separationHappened(default, null): Bool;
    public var separationAngle(default, null): Float;

    public var obj1Immovable: Bool;
    public var obj2Immovable: Bool;


    public inline function new(?object1: Collider, ?object2: Collider)
    {
        set(object1, object2);
    }


    @:allow(quadtree.QuadTree)
    function set(object1: Collider, object2: Collider)
    {
        this.object1 = object1;
        obj1Immovable = false;
        this.object2 = object2;
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
}

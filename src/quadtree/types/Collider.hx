package quadtree.types;


interface Collider
{
    /** The width of the area. **/
    public var areaType(default, never): CollisionAreaType;


    /** Whether or not the object can participate in collisions. **/
    public var collisionsEnabled(default, never): Bool;


    /** Function called from the quad tree when the object is overlapping with another. **/
    public function onOverlap(other: Collider): Void;


    /** 
        Called by `Physics.separate()` with the movement that should be applied to this oobject
        on each axis in order to separate from another colliding object.
    **/
    public function moveToSeparate(deltaX: Float, deltaY: Float): Void;
}

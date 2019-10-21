package quadtree.types;


interface Collider
{
    /** The width of the area. **/
    public var areaType(default, never): CollisionAreaType;


    /** Whether or not the object can participate in collisions. **/
    public var collisionsEnabled(default, never): Bool;


    /** Function called from the quad tree when the object is overlapping with another. **/
    public function onOverlap(other: Collider): Void;
}

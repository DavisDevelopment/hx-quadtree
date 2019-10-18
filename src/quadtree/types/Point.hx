package quadtree.types;


interface Point
{
    /** The width of the area. **/
    public var areaType(default, never): CollisionAreaType;


    /** Whether or not the object can participate in collisions. **/
    public var collisionsEnabled(default, never): Bool;


    /** The x-coordinate of the point. **/
    public var x(default, never): Float;
    

    /** The y-coordinate of the point. **/
    public var y(default, never): Float;


    /** Function called from the quad tree when the object is overlapping with another. **/
    public function onOverlap(other: Point): Void;
}

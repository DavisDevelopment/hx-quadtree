package quadtree.types;


interface Circle extends Collider
{
    /** The x-coordinate of the center of the circle. **/
    public var centerX(default, never): Float;


    /** The y-coordinate of the center of the circle. **/
    public var centerY(default, never): Float;


    /** The circle's radius. **/
    public var radius(default, never): Float;
}

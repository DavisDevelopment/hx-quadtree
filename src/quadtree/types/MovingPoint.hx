package quadtree.types;


interface MovingPoint extends Point
{
    /** The x-coordinate of the point on the previous frame. **/
    public var lastX(default, never): Float;
    
    
    /** The y-coordinate of the point on the previous frame. **/
    public var lastY(default, never): Float;
}

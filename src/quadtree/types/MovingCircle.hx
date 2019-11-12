package quadtree.types;


interface MovingCircle extends Circle
{
    /** The x-coordinate of the circle's center on the previous frame. **/
    public var lastX(default, never): Float;
    
    
    /** The y-coordinate of the circle's center on the previous frame. **/
    public var lastY(default, never): Float;
}

package quadtree.types;


interface MovingRectangle extends Rectangle
{
    /** The x-coordinate of the rectangle on the previous frame. **/
    public var lastX(default, never): Float;
    
    
    /** The y-coordinate of the rectangle on the previous frame. **/
    public var lastY(default, never): Float;
}

package quadtree.types;


interface Rectangle extends Point
{
    /** The width of the rectangle. **/
    public var width(default, never): Float;
    
    
    /** The height of the rectangle. **/
    public var height(default, never): Float;


    /** The rotation angle (in radians) of the rectangle around its center. **/
    public var angle(default, never): Float;
}

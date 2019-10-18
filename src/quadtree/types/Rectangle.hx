package quadtree.types;


interface Rectangle extends Point
{
    /** The width of the area. **/
    public var width(default, never): Float;
    
    
    /** The height of the area. **/
    public var height(default, never): Float;    
}

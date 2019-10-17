package quadtree.types;


interface Rectangle extends Point
{
    /** The width of the area. **/
    public var width(default, never): Int;
    
    /** The height of the area. **/
    public var height(default, never): Int;    
}

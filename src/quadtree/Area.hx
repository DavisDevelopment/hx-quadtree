package quadtree;


interface Area
{
    /** The x-coordinate of the top-left position of the area. **/
    public var x(default, never): Int;
    
    /** The y-coordinate of the top-left position of the area. **/
    public var y(default, never): Int;

    /** The width of the area. **/
    public var width(default, never): Int;
    
    /** The height of the area. **/
    public var height(default, never): Int;
}

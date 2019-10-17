package quadtree.types;


@:enum
abstract CollisionAreaType(Int) 
{
    var Point     = 0;
    var Rectangle = 1;
    var Circle    = 2;
}


interface Point
{
    /** The width of the area. **/
    public var areaType(default, never): CollisionAreaType;

    /** The x-coordinate of the point. **/
    public var x(default, never): Int;
    
    /** The y-coordinate of the point. **/
    public var y(default, never): Int;
}
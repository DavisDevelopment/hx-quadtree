package quadtree;


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
    public var areaType: CollisionAreaType;

    /** The x-coordinate of the point. **/
    public var x: Int;
    
    /** The y-coordinate of the point. **/
    public var y: Int;
}
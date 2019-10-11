package quadtree;


@:enum
abstract AreaType(Int) 
{
    var Rectangle = 0;
    var Circle    = 1;
}


interface Area extends Point
{
    /** The width of the area. **/
    public var areaType(default, never): AreaType;

    /** The width of the area. **/
    public var width(default, never): Int;
    
    /** The height of the area. **/
    public var height(default, never): Int;
}

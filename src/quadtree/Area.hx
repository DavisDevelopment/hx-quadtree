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
    public var areaType: AreaType;

    /** The width of the area. **/
    public var width: Int;
    
    /** The height of the area. **/
    public var height: Int;
}

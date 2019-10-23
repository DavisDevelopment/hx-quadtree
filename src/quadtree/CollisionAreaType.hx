package quadtree;


@:enum
abstract CollisionAreaType(Int) 
{
    var Undefined       = 0;
    var Point           = 1;
    var MovingPoint     = 2;
    var Rectangle       = 3;
    var MovingRectangle = 4;
    var Circle          = 5;
    var Polygon         = 6;
}

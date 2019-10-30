package quadtree;


@:enum
abstract CollisionAreaType(Int) to Int
{
    var Undefined       = 1 << 0;
    var Point           = 1 << 1;
    var MovingPoint     = 1 << 2;
    var Rectangle       = 1 << 3;
    var MovingRectangle = 1 << 4;
    var Circle          = 1 << 5;
    var MovingCircle    = 1 << 6;
    var Polygon         = 1 << 7;
    var MovingPolygon   = 1 << 8;
}

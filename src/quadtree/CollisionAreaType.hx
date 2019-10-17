package quadtree;


@:enum
abstract CollisionAreaType(Int) 
{
    var Point           = 0;
    var MovingPoint     = 1;
    var Rectangle       = 2;
    var MovingRectangle = 3;
    var Circle          = 4;
}

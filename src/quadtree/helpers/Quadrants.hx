package quadtree.helpers;


@:enum
abstract Quadrants(Int) from Int to Int
{
    var None     = 0;
    var TopLeft  = 1 << 0;
    var TopRight = 1 << 1;
    var BotLeft  = 1 << 2;
    var BotRight = 1 << 3;


    @:op(A & B)
    public inline function bitwiseAnd(quadrant: Quadrants): Bool
    {
        return (this & quadrant) > 0;
    }
}

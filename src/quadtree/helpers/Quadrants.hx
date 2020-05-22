package quadtree.helpers;


@:enum
abstract Quadrants(Int) from Int to Int
{
    var TopLeft  = 1 << 0;
    var TopRight = 1 << 1;
    var BotLeft  = 1 << 2;
    var BotRight = 1 << 3;
}

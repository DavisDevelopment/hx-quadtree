package quadtree;


class RectangleUtils
{
    public static inline function contains(rect: Area, other: Area): Bool
    {
        return other != null
            && rect.x <= other.x
            && rect.y <= other.y
            && rect.x + rect.width >= other.x + other.width
            && rect.y + rect.height >= other.y + other.height;
    }
}

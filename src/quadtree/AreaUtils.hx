package quadtree;


class AreaUtils
{
    public static inline function containsAreaInArea(area: Area, other: Area): Bool
    {
        return other != null
            && area.x <= other.x
            && area.y <= other.y
            && area.x + area.width >= other.x + other.width
            && area.y + area.height >= other.y + other.height;
    }
    

    public static inline function intersectsAreaWithArea(area: Area, other: Area): Bool
    {
        return other != null
            && area.x + area.width > other.x
            && area.y + area.height > other.y
            && area.x < other.x + other.width
            && area.y < other.y + other.height;
    }


    public static inline function containsPointInArea(area: Area, other: Point): Bool
    {
        return other != null
            && area.x <= other.x
            && area.y <= other.y
            && area.x + area.width >= other.x
            && area.y + area.height >= other.y;
    }
}

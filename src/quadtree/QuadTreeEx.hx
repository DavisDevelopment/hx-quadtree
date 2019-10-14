package quadtree;


@:access(quadtree.QuadTree)
class QuadTreeEx
{
    public static inline function containsArea(qt: QuadTree, leftEdge: Int, topEdge: Int, rightEdge: Int, botEdge: Int): Bool
    {
        return qt.leftEdge <= leftEdge
            && qt.topEdge <= topEdge
            && qt.rightEdge >= rightEdge
            && qt.botEdge >= botEdge;
    }
    

    public static inline function intersectsWithArea(qt: QuadTree, other: Area): Bool
    {
        return other != null
            && qt.rightEdge > other.x
            && qt.botEdge > other.y
            && qt.leftEdge < other.x + other.width
            && qt.topEdge < other.y + other.height;
    }


    public static inline function containsPoint(qt: QuadTree, other: Point): Bool
    {
        return other != null
            && qt.leftEdge <= other.x
            && qt.topEdge <= other.y
            && qt.rightEdge >= other.x
            && qt.botEdge >= other.y;
    }
}

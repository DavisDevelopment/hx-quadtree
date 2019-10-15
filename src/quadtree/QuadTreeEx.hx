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


    public static inline function isContainedInArea(qt: QuadTree, leftEdge: Int, topEdge: Int, rightEdge: Int, botEdge: Int): Bool
    {
        return qt.leftEdge >= leftEdge
            && qt.topEdge >= topEdge
            && qt.rightEdge <= rightEdge
            && qt.botEdge <= botEdge;
    }


    public static inline function intersectsTopLeft(qt: QuadTree, leftEdge: Int, topEdge: Int, rightEdge: Int, botEdge: Int): Bool
    {
        return rightEdge > qt.leftEdge
            && leftEdge < qt.midpointX
            && botEdge > qt.topEdge
            && topEdge < qt.midpointY;
    }


    public static inline function intersectsTopRight(qt: QuadTree, leftEdge: Int, topEdge: Int, rightEdge: Int, botEdge: Int): Bool
    {
        return rightEdge > qt.midpointX
            && leftEdge < qt.rightEdge
            && botEdge > qt.topEdge
            && topEdge < qt.midpointY;
    }


    public static inline function intersectsBotRight(qt: QuadTree, leftEdge: Int, topEdge: Int, rightEdge: Int, botEdge: Int): Bool
    {
        return rightEdge > qt.midpointX
            && leftEdge < qt.rightEdge
            && botEdge > qt.midpointY
            && topEdge < qt.botEdge;
    }


    public static inline function intersectsBotLeft(qt: QuadTree, leftEdge: Int, topEdge: Int, rightEdge: Int, botEdge: Int): Bool
    {
        return rightEdge > qt.leftEdge
            && leftEdge < qt.midpointX
            && botEdge > qt.midpointY
            && topEdge < qt.botEdge;
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

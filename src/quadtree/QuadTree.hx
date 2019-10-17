package quadtree;

import quadtree.types.MovingRectangle;
import quadtree.types.Point;
import quadtree.types.Rectangle;

using quadtree.QuadTreeEx;
using quadtree.extensions.PointEx;
using quadtree.extensions.RectangleEx;
using quadtree.extensions.MovingRectangleEx;


class QuadTree
{
    var objects0: Array<Point>;
    var objects1: Array<Point>;

    var topLeftTree: QuadTree;
    var topRightTree: QuadTree;
    var botLeftTree: QuadTree;
    var botRightTree: QuadTree;

    var leftEdge: Int;
    var topEdge: Int;
    var rightEdge: Int;
    var botEdge: Int;
    var halfWidth: Int;
    var halfHeight: Int;
    var midpointX: Int;
    var midpointY: Int;

    var maxDepth: Int;


    public inline function new(x: Int, y: Int, width: Int, height: Int, maxDepth: Int = 5)
    {
        reset(x, y, width, height, maxDepth);
    }


    function reset(x: Int, y: Int, width: Int, height: Int, maxDepth: Int)
    {
        objects0 = new Array<Point>();
        objects1 = new Array<Point>();

        topLeftTree = null;
        topRightTree = null;
        botLeftTree = null;
        botRightTree = null;

        leftEdge = x;
        topEdge = y;
        rightEdge = x + width;
        botEdge = y + height;
        halfWidth = Std.int(width / 2);
        halfHeight = Std.int(height / 2);
        midpointX = leftEdge + halfWidth;
        midpointY = topEdge + halfHeight;

        this.maxDepth = maxDepth;
    }


    public function load(objectGroup: Array<Point>, ?otherObjectGroup: Array<Point> = null)
    {
        for (obj in objectGroup)
        {
            add(obj, 0);
        }
        if (otherObjectGroup != null)
        {
            for (obj in otherObjectGroup)
            {
                add(obj, 1);
            }
        }
    }


    public function add(object: Point, list: Int = 0)
    {
        switch object.areaType
        {
            case CollisionAreaType.Point | CollisionAreaType.MovingPoint:
                addPoint(cast(object, Point), list);

            case CollisionAreaType.Rectangle | CollisionAreaType.MovingRectangle:
                addRectangle(cast(object, Rectangle), list);

            case _:
                throw "Must specify an areaType";
        }
    }


    public function execute()
    {
        if (canSubdivide())
        {
            // Leaf node, check for collisions here.

            collisionCheckHere();
        }
        else
        {
            // Internal node, recursively check on children.

            if (topLeftTree != null)
            {
                topLeftTree.execute();
            }
            if (topRightTree != null)
            {
                topRightTree.execute();
            }
            if (botLeftTree != null)
            {
                botLeftTree.execute();
            }
            if (botRightTree != null)
            {
                botRightTree.execute();
            }
        }
    }


    function addRectangle(rect: Rectangle, list: Int = 0)
    {
        final objLeftEdge: Int = rect.x;
        final objTopEdge: Int = rect.y;
        final objRightEdge: Int = rect.x + rect.width;
        final objBottomEdge: Int = rect.y + rect.height;

        // Check if the entire node fits inside the object.
        if (!canSubdivide() || this.isContainedInArea(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addHere(rect, list);
            return;
        }

        // Check if the object fits completely inside one of the quadrants.
        if (objLeftEdge > leftEdge && objRightEdge < midpointX)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                addToTopLeft(rect, list);
                return;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                addToBotLeft(rect, list);
                return;
            }
        }
        if (objLeftEdge > midpointX && objRightEdge < rightEdge)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                addToTopRight(rect, list);
                return;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                addToBotRight(rect, list);
                return;
            }
        }

        // Object didn't completely fit in any quadrant, check for partial overlaps.
        if (this.intersectsTopLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToTopLeft(rect, list);
        }
        if (this.intersectsTopRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToTopRight(rect, list);
        }
        if (this.intersectsBotRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToBotRight(rect, list);
        }
        if (this.intersectsBotLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToBotLeft(rect, list);
        }
    }


    function addPoint(point: Point, list: Int = 0)
    {
        if (!canSubdivide() && this.containsPoint(point))
        {
            addHere(point, list);
            return;
        }

        if (point.x < midpointX)
        {
            if (point.y < midpointY)
            {
                addToTopLeft(point, list);
            }
            else
            {
                addToBotLeft(point, list);
            }
        }
        else
        {
            if (point.y < midpointY)
            {
                addToTopRight(point, list);
            }
            else
            {
                addToBotRight(point, list);
            }
        }
    }


    function addHere(object: Point, list: Int = 0) 
    {
        if (canSubdivide())
        {
            addToTopLeft(object, list);
            addToTopRight(object, list);
            addToBotLeft(object, list);
            addToBotRight(object, list);
        }
        else
        { 
            switch list
            {
                case 0:
                    objects0.push(object);

                case 1:
                    objects1.push(object);

                case _:
                    throw "Invalid list";
            }
        }
    }


    function collisionCheckHere()
    {
        for (i0 in 0...objects0.length)
        {
            switch objects0[0].areaType
            {
                case CollisionAreaType.Point:
                    collisionCheckPoint(i0);

                case CollisionAreaType.Rectangle:
                    collisionCheckRectangle(i0);

                case CollisionAreaType.MovingRectangle:
                    collisionCheckMovingRectangle(i0);
                
                case _: 
                    throw "Not implemented";
            }
        }
    }


    function onDetectedCollision(obj0: Point, obj1: Point)
    {

    }


    inline function canSubdivide(): Bool
    {
        return maxDepth > 0;
    }


    inline function useBothLists(): Bool
    {
        return objects1.length > 0;
    }

    // =============================================================================
    //
    //                       TYPE-SPECIFIC COLLISION CHECKS
    //
    // =============================================================================

    function collisionCheckPoint(index: Int) 
    {
        var point: Point = objects0[index];

        var otherList: Array<Point> = useBothLists() ? objects1 : objects1;
        var firstIndex: Int = useBothLists() ? 0 : index + 1;

        for (i1 in firstIndex...otherList.length)
        {
            var other: Point = otherList[i1];

            if (point.intersectsWith(other))
            {
                onDetectedCollision(point, other);
            }
        }
    }


    function collisionCheckRectangle(index: Int)
    {
        var rect: Rectangle = cast(objects0[index], Rectangle);

        var otherList: Array<Point> = useBothLists() ? objects1 : objects1;
        var firstIndex: Int = useBothLists() ? 0 : index + 1;

        for (i1 in firstIndex...otherList.length)
        {
            var other: Point = otherList[i1];

            if (rect.intersectsWith(other))
            {
                onDetectedCollision(rect, other);
            }
        }
    }


    function collisionCheckMovingRectangle(index: Int)
    {
        var rect: MovingRectangle = cast(objects0[index], MovingRectangle);
        var hullX: Float = rect.hullX();
        var hullY: Float = rect.hullY();
        var hullWidth: Float = rect.hullWidth();
        var hullHeight: Float = rect.hullHeight();

        var otherList: Array<Point> = useBothLists() ? objects1 : objects1;
        var firstIndex: Int = useBothLists() ? 0 : index + 1;

        for (i1 in firstIndex...otherList.length)
        {
            var other: Point = otherList[i1];

            if (MovingRectangleEx.intersectsWith(hullX, hullY, hullWidth, hullHeight, other))
            {
                onDetectedCollision(rect, other);
            }
        }
    }


    // =============================================================================
    //
    //                             HELPER FUNCTIONS
    //
    // =============================================================================

    inline function addToTopLeft(point: Point, list: Int = 0)
    {
        if (topLeftTree == null)
        {
            topLeftTree = new QuadTree(leftEdge, topEdge, halfWidth, halfHeight, maxDepth - 1);
        }
        topLeftTree.add(point, list);
    }


    inline function addToTopRight(point: Point, list: Int = 0)
    {
        if (topRightTree == null)
        {
            topRightTree = new QuadTree(midpointX, topEdge, halfWidth, halfHeight, maxDepth - 1);
        }
        topRightTree.add(point, list);
    }


    inline function addToBotRight(point: Point, list: Int = 0)
    {
        if (botRightTree == null)
        {
            botRightTree = new QuadTree(midpointX, midpointY, halfWidth, halfHeight, maxDepth - 1);
        }
        botRightTree.add(point, list);
    }


    inline function addToBotLeft(point: Point, list: Int = 0)
    {
        if (botLeftTree == null)
        {
            botLeftTree = new QuadTree(leftEdge, midpointY, halfWidth, halfHeight, maxDepth - 1);
        }
        botLeftTree.add(point, list);
    }


    @IgnoreCover
    public function visualize(buf: StringBuf, space: String = "")
    {
        buf.add('${space}[$leftEdge, $topEdge, $rightEdge, $botEdge]\n');
        buf.add('${space}objects0: [${objects0.length}]\n');
        buf.add('${space}objects1: [${objects1.length}]\n');
        if (topLeftTree != null)
        {
            buf.add('${space}topLeftTree:\n');
            topLeftTree.visualize(buf, space + "    ");
        }
        if (topRightTree != null)
        {
            buf.add('${space}topRightTree:\n');
            topRightTree.visualize(buf, space + "    ");
        }
        if (botLeftTree != null)
        {
            buf.add('${space}botLeftTree:\n');
            botLeftTree.visualize(buf, space + "    ");
        }
        if (botRightTree != null)
        {
            buf.add('${space}botRightTree:\n');
            botRightTree.visualize(buf, space + "    ");
        }
    }
}

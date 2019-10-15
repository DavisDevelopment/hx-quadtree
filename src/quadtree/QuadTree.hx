package quadtree;

import quadtree.areas.Rectangle;
import quadtree.Point;

using quadtree.QuadTreeEx;


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


    public function add(object: Point, list: Int = 0)
    {
        if (Std.is(object, Area))
        {
            addArea(cast(object, Area), list);
        }
        else
        {
            addPoint(cast(object, Point), list);
        }
    }


    function addArea(area: Area, list: Int = 0)
    {
        final objLeftEdge: Int = area.x;
        final objTopEdge: Int = area.y;
        final objRightEdge: Int = area.x + area.width;
        final objBottomEdge: Int = area.y + area.height;

        // Check if the entire node fits inside the object.
        if (!canSubdivide() || this.isContainedInArea(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToList(area, list);
            return;
        }

        // Check if the object fits completely inside one of the quadrants.
        if (objLeftEdge > leftEdge && objRightEdge < midpointX)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                addToTopLeft(area, list);
                return;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                addToBotLeft(area, list);
                return;
            }
        }
        if (objLeftEdge > midpointX && objRightEdge < rightEdge)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                addToTopRight(area, list);
                return;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                addToBotRight(area, list);
                return;
            }
        }

        // Object didn't completely fit in any quadrant, check for partial overlaps.
        if (this.intersectsTopLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToTopLeft(area, list);
        }
        if (this.intersectsTopRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToTopRight(area, list);
        }
        if (this.intersectsBotRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToBotRight(area, list);
        }
        if (this.intersectsBotLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToBotLeft(area, list);
        }
    }


    function addPoint(point: Point, list: Int = 0)
    {
        if (!canSubdivide() && this.containsPoint(point))
        {
            addToList(point, list);
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


    function addToList(object: Point, list: Int = 0) 
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


    inline function canSubdivide(): Bool
    {
        return maxDepth > 0;
    }


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

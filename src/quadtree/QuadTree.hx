package quadtree;

import quadtree.areas.Rectangle;
import quadtree.Point;
import quadtree.areas.BoundingBox;

using quadtree.QuadTreeEx;


class QuadTree
{
    var objects0: Array<Point>;
    var objects1: Array<Point>;

    var topLeft: QuadTree;
    var topRight: QuadTree;
    var botLeft: QuadTree;
    var botRight: QuadTree;

    var leftEdge: Int;
    var topEdge: Int;
    var rightEdge: Int;
    var botEdge: Int;
    var halfWidth: Int;
    var halfHeight: Int;
    var midpointX: Int;
    var midpointY: Int;

    var depth: Int;


    public function new(?boundaries: Rectangle)
    {
        reset(boundaries);
    }


    function reset(?boundaries: Rectangle)
    {
        boundaries = boundaries != null ? boundaries : BoundingBox.Max;

        objects0 = new Array<Point>();
        objects1 = new Array<Point>();

        leftEdge = boundaries.x;
        topEdge = boundaries.y;
        rightEdge = boundaries.x + boundaries.width;
        botEdge = boundaries.y + boundaries.height;
        halfWidth = Std.int(boundaries.width / 2);
        halfHeight = Std.int(boundaries.height / 2);
        midpointX = leftEdge + halfWidth;
        midpointY = topEdge + halfHeight;

        depth = 0;
    }


    public function add(object: Point, list: Int = 0)
    {
        if (Std.is(object, Point))
        {
            addPoint(cast(object, Point), list);
        }
        else
        {
            addArea(cast(object, Area), list);
        }
    }


    function addArea(area: Area, list: Int = 0): Bool
    {
        var objLeftEdge: Int = area.x;
        var objTopEdge: Int = area.y;
        var objRightEdge: Int = area.x + area.width;
        var objBottomEdge: Int = area.y + area.height;

        if (this.containsArea(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToList(area, list);
            return true;
        }

        return false;        
    }


    function addPoint(point: Point, list: Int = 0)
    {
        
    }


    function addToList(object: Point, list: Int = 0) 
    {
        switch list
        {
            case 0:
                objects0.push(object);

            case 1:
                objects1.push(object);
        }
    }
}

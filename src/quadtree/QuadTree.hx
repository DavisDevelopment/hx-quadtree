package quadtree;

import quadtree.types.MovingPoint;
import quadtree.types.MovingRectangle;
import quadtree.types.Point;
import quadtree.types.Rectangle;

using quadtree.QuadTreeEx;
using quadtree.extensions.PointEx;
using quadtree.extensions.RectangleEx;
using quadtree.extensions.MovingPointEx;
using quadtree.extensions.MovingRectangleEx;


class QuadTree
{
    var objects0: Array<Point>;
    var objects1: Array<Point>;
    var parent: QuadTree;

    var topLeftTree: QuadTree;
    var topRightTree: QuadTree;
    var botLeftTree: QuadTree;
    var botRightTree: QuadTree;

    var leftEdge: Float;
    var topEdge: Float;
    var rightEdge: Float;
    var botEdge: Float;
    var halfWidth: Float;
    var halfHeight: Float;
    var midpointX: Float;
    var midpointY: Float;

    var maxDepth: Int;

    var overlapProcessCallback: (Dynamic, Dynamic) -> Bool;


    public inline function new(x: Float, y: Float, width: Float, height: Float, maxDepth: Int = 5)
    {
        reset(x, y, width, height, maxDepth);
    }


    function reset(?x: Float, ?y: Float, ?width: Float, ?height: Float, ?maxDepth: Int)
    {
        objects0 = new Array<Point>();
        objects1 = new Array<Point>();

        topLeftTree = null;
        topRightTree = null;
        botLeftTree = null;
        botRightTree = null;

        // Apply defaults.
        x = x != null ? x : leftEdge;
        y = y != null ? y : topEdge;
        width = width != null ? width : rightEdge - x;
        height = height != null ? height : botEdge - x;
        this.maxDepth = maxDepth != null ? maxDepth : this.maxDepth;

        // Update boundaries.
        leftEdge = x;
        topEdge = y;
        rightEdge = x + width;
        botEdge = y + height;
        halfWidth = Std.int(width / 2);
        halfHeight = Std.int(height / 2);
        midpointX = leftEdge + halfWidth;
        midpointY = topEdge + halfHeight;
    }


    /**
        Load objects into the quad tree.

        On collisions, objects in `objectGroup` will have their `onOverlap()` method called before
        the respective object in `otherObjectGroup`. When not using the second list and collisions
        are only checked between objects in the first, `onOverlap()` will be called in an undefined order.

        @param objectGroup A list of objects that should be checked for collisions.
                           If `otherObjectGroup` is not provided, then objects in this group will
                           be checked against each other.
        @param otherObjectGroup An optional second group of objects to check for collisions
                                against the ones in `objectGroup`.
    **/
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


    /**
        Sets a callback method for processing collisions.

        The given function, if set, will be called when two objects intersect, with the objects as arguments.
        If it is set, then `onOverlap()` will be called on the overlapping objects only if the processing
        callback returns `true`.

        This can be used to handle special overlap cases not covered by this library, or in general choosing
        when two objects should be notified of their collisions.

        The separation of the two overlapping objects in a physics system could also take place inside this callback.

        **Note:** When using two groups, the first argument passed to the callback function will always be the object
        from the first group.
    **/
    public inline function setOverlapProcessCallback(overlapProcessCallback: (Dynamic, Dynamic) -> Bool)
    {
        this.overlapProcessCallback = overlapProcessCallback;
    }


    /**
        The quad tree's main method.
        Traverses the tree and checks for overlapping objects.
    **/
    public function execute()
    {
        if (canSubdivide())
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
        else
        {
            // Leaf node, check for collisions here.

            collisionCheckHere();
        }
    }


    function add(object: Point, group: Int = 0)
    {
        switch object.areaType
        {
            case CollisionAreaType.Point | CollisionAreaType.MovingPoint:
                addPoint(cast(object, Point), group);

            case CollisionAreaType.Rectangle | CollisionAreaType.MovingRectangle:
                addRectangle(cast(object, Rectangle), group);

            case _:
                throw "Must specify an areaType";
        }
    }


    function addRectangle(rect: Rectangle, group: Int = 0)
    {
        final objLeftEdge: Float = rect.x;
        final objTopEdge: Float = rect.y;
        final objRightEdge: Float = rect.x + rect.width;
        final objBottomEdge: Float = rect.y + rect.height;

        // Check if the entire node fits inside the object.
        if (!canSubdivide() || this.isContainedInArea(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addHere(rect, group);
            return;
        }

        // Check if the object fits completely inside one of the quadrants.
        if (objLeftEdge > leftEdge && objRightEdge < midpointX)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                addToTopLeft(rect, group);
                return;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                addToBotLeft(rect, group);
                return;
            }
        }
        if (objLeftEdge > midpointX && objRightEdge < rightEdge)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                addToTopRight(rect, group);
                return;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                addToBotRight(rect, group);
                return;
            }
        }

        // Object didn't completely fit in any quadrant, check for partial overlaps.
        if (this.intersectsTopLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToTopLeft(rect, group);
        }
        if (this.intersectsTopRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToTopRight(rect, group);
        }
        if (this.intersectsBotRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToBotRight(rect, group);
        }
        if (this.intersectsBotLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToBotLeft(rect, group);
        }
    }


    function addPoint(point: Point, group: Int = 0)
    {
        if (!canSubdivide() && this.containsPoint(point))
        {
            addHere(point, group);
            return;
        }

        if (point.x < midpointX)
        {
            if (point.y < midpointY)
            {
                addToTopLeft(point, group);
            }
            else
            {
                addToBotLeft(point, group);
            }
        }
        else
        {
            if (point.y < midpointY)
            {
                addToTopRight(point, group);
            }
            else
            {
                addToBotRight(point, group);
            }
        }
    }


    function addHere(object: Point, group: Int = 0) 
    {
        if (canSubdivide())
        {
            addToTopLeft(object, group);
            addToTopRight(object, group);
            addToBotLeft(object, group);
            addToBotRight(object, group);
        }
        else
        { 
            switch group
            {
                case 0:
                    objects0.push(object);

                case 1:
                    objects1.push(object);

                case _:
                    throw "Invalid group.";
            }
        }
    }


    function collisionCheckHere()
    {
        for (i0 in 0...objects0.length)
        {
            if (!objects0[i0].collisionsEnabled)
                continue;

            switch objects0[i0].areaType
            {
                case CollisionAreaType.Point:
                    collisionCheckPoint(i0);

                case CollisionAreaType.MovingPoint:
                    collisionCheckMovingPoint(i0);

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
        if (parent == null)
        {
            // Root node, process collision here.

            if (overlapProcessCallback == null || overlapProcessCallback(obj0, obj1))
            {
                obj0.onOverlap(obj1);
                obj1.onOverlap(obj0);
            }
        }
        else
        {
            // Leaf or internal node, process collision on the parent.

            parent.onDetectedCollision(obj0, obj1);
        }
    }


    inline function canSubdivide(): Bool
    {
        return maxDepth > 0;
    }

    // =============================================================================
    //
    //                       TYPE-SPECIFIC COLLISION CHECKS
    //
    // =============================================================================

    function collisionCheckPoint(index: Int)
    {
        var point: Point = objects0[index];

        var otherList = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Point = otherList[i1];

            if (!other.collisionsEnabled)
                continue;
            
            if (point.intersectsWith(other))
            {
                onDetectedCollision(point, other);
            }
        }
    }


    function collisionCheckMovingPoint(index: Int)
    {
        var movingPoint: MovingPoint = cast(objects0[index], MovingPoint);

        var otherList = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Point = otherList[i1];

            if (!other.collisionsEnabled)
                continue;

            if (movingPoint.intersectsWith(other))
            {
                onDetectedCollision(movingPoint, other);
            }
        }
    }


    function collisionCheckRectangle(index: Int)
    {
        var rect: Rectangle = cast(objects0[index], Rectangle);

        var otherList = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Point = otherList[i1];

            if (!other.collisionsEnabled)
                continue;

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

        var otherList: Array<Point> = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Point = otherList[i1];

            if (!other.collisionsEnabled)
                continue;

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

    inline function useBothLists(): Bool
    {
        return objects1.length > 0;
    }


    inline function listToCheck(): Array<Point>
    {
        return useBothLists() ? objects1 : objects0;
    }


    inline function listToCheckFirstIndex(objBeingCheckedIndex: Int) : Int
    {
        return useBothLists() ? 0 : objBeingCheckedIndex + 1;
    }


    inline function addToTopLeft(point: Point, group: Int = 0)
    {
        if (topLeftTree == null)
        {
            topLeftTree = new QuadTree(leftEdge, topEdge, halfWidth, halfHeight, maxDepth - 1);
            topLeftTree.parent = this;
        }
        topLeftTree.add(point, group);
    }


    inline function addToTopRight(point: Point, group: Int = 0)
    {
        if (topRightTree == null)
        {
            topRightTree = new QuadTree(midpointX, topEdge, halfWidth, halfHeight, maxDepth - 1);
            topRightTree.parent = this;
        }
        topRightTree.add(point, group);
    }


    inline function addToBotRight(point: Point, group: Int = 0)
    {
        if (botRightTree == null)
        {
            botRightTree = new QuadTree(midpointX, midpointY, halfWidth, halfHeight, maxDepth - 1);
            botRightTree.parent = this;
        }
        botRightTree.add(point, group);
    }


    inline function addToBotLeft(point: Point, group: Int = 0)
    {
        if (botLeftTree == null)
        {
            botLeftTree = new QuadTree(leftEdge, midpointY, halfWidth, halfHeight, maxDepth - 1);
            botLeftTree.parent = this;
        }
        botLeftTree.add(point, group);
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

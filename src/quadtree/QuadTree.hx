package quadtree;

import quadtree.gjk.Gjk;
import quadtree.types.Polygon;
import quadtree.extensions.PolygonEx;
import quadtree.types.Circle;
import quadtree.types.Collider;
import quadtree.types.MovingPoint;
import quadtree.types.MovingRectangle;
import quadtree.types.Point;
import quadtree.types.Rectangle;

using quadtree.QuadTreeEx;
using quadtree.extensions.PointEx;
using quadtree.extensions.CircleEx;
using quadtree.extensions.PolygonEx;
using quadtree.extensions.MovingPointEx;
using quadtree.extensions.RectangleEx;
using quadtree.extensions.MovingRectangleEx;


class QuadTree
{
    var objects0: Array<Collider>;
    var objects1: Array<Collider>;
    var parent: QuadTree;
    var gjk: Gjk;

    var topLeftTree: QuadTree;
    var topRightTree: QuadTree;
    var botLeftTree: QuadTree;
    var botRightTree: QuadTree;

    var topLeftBounds: SubtreeBounds;
    var topRightBounds: SubtreeBounds;
    var botLeftBounds: SubtreeBounds;
    var botRightBounds: SubtreeBounds;
    
    var leftEdge: Float;
    var topEdge: Float;
    var rightEdge: Float;
    var botEdge: Float;
    var halfWidth: Float;
    var halfHeight: Float;
    var midpointX: Float;
    var midpointY: Float;

    var maxDepth: Int;
    var useBothLists: Bool;

    var overlapProcessCallback: (Dynamic, Dynamic) -> Bool;


    public inline function new(x: Float, y: Float, width: Float, height: Float, maxDepth: Int = 5)
    {
        gjk = new Gjk();
        reset(x, y, width, height, maxDepth);
    }


    function reset(?x: Float, ?y: Float, ?width: Float, ?height: Float, ?maxDepth: Int)
    {
        objects0 = new Array<Collider>();
        objects1 = new Array<Collider>();

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

        if (canSubdivide())
        {
            topLeftBounds = new SubtreeBounds(leftEdge, topEdge, halfWidth, halfHeight);
            topRightBounds = new SubtreeBounds(midpointX, topEdge, halfWidth, halfHeight);
            botLeftBounds = new SubtreeBounds(leftEdge, midpointY, halfWidth, halfHeight);
            botRightBounds = new SubtreeBounds(midpointX, midpointY, halfWidth, halfHeight);
        }
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
    public function load(objectGroup: Array<Collider>, ?otherObjectGroup: Array<Collider> = null)
    {
        useBothLists = (otherObjectGroup != null);

        for (obj in objectGroup)
        {
            add(obj, 0);
        }

        if (useBothLists)
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


    function add(object: Collider, group: Int = 0)
    {
        switch object.areaType
        {
            case CollisionAreaType.Point | CollisionAreaType.MovingPoint:
                addPoint(cast(object, Point), group);

            case CollisionAreaType.Rectangle | CollisionAreaType.MovingRectangle:
                addRectangle(cast(object, Rectangle), group);

            case CollisionAreaType.Circle:
                addCircle(cast(object, Circle), group);

            case CollisionAreaType.Polygon:
                addPolygon(cast(object, Polygon), group);

            case _:
                throw "Must specify an areaType";
        }
    }


    function addRectangle(rect: Rectangle, group: Int)
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

        addRectBoundObject(rect, objLeftEdge, objTopEdge, objRightEdge, objBottomEdge, group);
    }


    function addPoint(point: Point, group: Int)
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


    function addCircle(circle: Circle, group: Int)
    {
        if (!canSubdivide())
        {
            addHere(circle, group);
            return;
        }

        /**
            For now, circles will be added as if they were rectangles.
            This can only lead to false positives, ending up in quadrants that don't overlap with them,
            and not false negatives, so collisions should not be missed.

            Doing so, saves a run through the GJK algorithm when adding circles,
            but with an error rate of (4 - pi) * (r^2) they will end up in extra quadrants.

            Both options may be measured in the future for comparison.
        **/
        
        final objLeftEdge: Float = circle.centerX - circle.radius;
        final objTopEdge: Float = circle.centerY - circle.radius;
        final objRightEdge: Float = circle.centerX + circle.radius;
        final objBottomEdge: Float = circle.centerY + circle.radius;
        
        addRectBoundObject(circle, objLeftEdge, objTopEdge, objRightEdge, objBottomEdge, group);
    }


    function addPolygon(polygon: Polygon, group: Int)
    {
        if (!canSubdivide())
        {
            addHere(polygon, group);
            return;
        }

        if (gjk.checkOverlap(topLeftBounds, polygon))
        {
            addToTopLeft(polygon, group);
        }
        if (gjk.checkOverlap(topRightBounds, polygon))
        {
            addToTopRight(polygon, group);
        }
        if (gjk.checkOverlap(botLeftBounds, polygon))
        {
            addToBotLeft(polygon, group);
        }
        if (gjk.checkOverlap(botRightBounds, polygon))
        {
            addToBotRight(polygon, group);
        }
    }


    @:generic
    function addRectBoundObject<T: Collider>(object: T, objLeftEdge: Float, objTopEdge: Float, objRightEdge: Float, objBottomEdge: Float, group: Int)
    {
        // Check if the object fits completely inside one of the quadrants.
        if (objLeftEdge > leftEdge && objRightEdge < midpointX)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                addToTopLeft(object, group);
                return;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                addToBotLeft(object, group);
                return;
            }
        }
        if (objLeftEdge > midpointX && objRightEdge < rightEdge)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                addToTopRight(object, group);
                return;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                addToBotRight(object, group);
                return;
            }
        }

        // Object didn't completely fit in any quadrant, check for partial overlaps.
        if (this.intersectsTopLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToTopLeft(object, group);
        }
        if (this.intersectsTopRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToTopRight(object, group);
        }
        if (this.intersectsBotRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToBotRight(object, group);
        }
        if (this.intersectsBotLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            addToBotLeft(object, group);
        }
    }


    function addHere(object: Collider, group: Int) 
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
                
                // Handle all other cases with the GJK algorithm.
                case _:
                    collisionCheckGeneric(i0);
            }
        }
    }


    function onDetectedCollision(obj0: Collider, obj1: Collider)
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


    function collisionCheckGeneric(index: Int)
    {
        var collider: Collider = objects0[index];

        var otherList: Array<Collider> = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Collider = otherList[i1];
            
            if (other.collisionsEnabled && gjk.checkOverlap(collider, other))
            {
                onDetectedCollision(collider, other);
            }
        }
    }


    function collisionCheckPoint(index: Int)
    {
        var point: Point = cast(objects0[index], Point);

        var otherList: Array<Collider> = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Collider = otherList[i1];
            
            if (other.collisionsEnabled && point.intersectsWith(other, gjk))
            {
                onDetectedCollision(point, other);
            }
        }
    }


    function collisionCheckMovingPoint(index: Int)
    {
        var movingPoint: MovingPoint = cast(objects0[index], MovingPoint);

        var otherList: Array<Collider> = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Collider = otherList[i1];

            if (other.collisionsEnabled && movingPoint.intersectsWith(other, gjk))
            {
                onDetectedCollision(movingPoint, other);
            }
        }
    }


    function collisionCheckRectangle(index: Int)
    {
        var rect: Rectangle = cast(objects0[index], Rectangle);

        var otherList: Array<Collider> = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Collider = otherList[i1];

            if (other.collisionsEnabled && rect.intersectsWith(other, gjk))
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

        var otherList: Array<Collider> = listToCheck();
        var firstIndex: Int = listToCheckFirstIndex(index);

        for (i1 in firstIndex...otherList.length)
        {
            var other: Collider = otherList[i1];

            if (other.collisionsEnabled && MovingRectangleEx.intersectsWith(rect, hullX, hullY, hullWidth, hullHeight, other, gjk))
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

    inline function listToCheck(): Array<Collider>
    {
        return useBothLists ? objects1 : objects0;
    }


    inline function listToCheckFirstIndex(objBeingCheckedIndex: Int) : Int
    {
        return useBothLists ? 0 : objBeingCheckedIndex + 1;
    }


    inline function addToTopLeft(collider: Collider, group: Int)
    {
        if (topLeftTree == null)
        {
            topLeftTree = createSubtree(topLeftBounds);
        }
        topLeftTree.add(collider, group);
    }


    inline function addToTopRight(collider: Collider, group: Int)
    {
        if (topRightTree == null)
        {
            topRightTree = createSubtree(topRightBounds);
        }
        topRightTree.add(collider, group);
    }


    inline function addToBotLeft(collider: Collider, group: Int)
    {
        if (botLeftTree == null)
        {
            botLeftTree = createSubtree(botLeftBounds);
        }
        botLeftTree.add(collider, group);
    }


    inline function addToBotRight(collider: Collider, group: Int)
    {
        if (botRightTree == null)
        {
            botRightTree = createSubtree(botRightBounds);
        }
        botRightTree.add(collider, group);
    }


    inline function createSubtree(bounds: SubtreeBounds): QuadTree
    {
        var tree: QuadTree = new QuadTree(bounds.x, bounds.y, bounds.width, bounds.height, maxDepth - 1);
        tree.useBothLists = useBothLists;
        tree.parent = this;
        return tree;
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


private class SubtreeBounds implements Rectangle
{
    public final areaType: CollisionAreaType = CollisionAreaType.Rectangle;
    public final collisionsEnabled: Bool = false;
    
    public final x: Float;
    public final y: Float;
    public final width: Float;
    public final height: Float;


    public function new(x: Float, y: Float, width: Float = 0, height: Float = 0)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }


    public function onOverlap(other: Collider): Void { }
}

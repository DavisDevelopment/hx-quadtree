package quadtree;

import quadtree.helpers.Quadrants;
import quadtree.gjk.Gjk;
import quadtree.types.Polygon;
import quadtree.types.Circle;
import quadtree.types.Collider;
import quadtree.types.MovingPoint;
import quadtree.types.MovingRectangle;
import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.helpers.BoundingBox;
import quadtree.helpers.LinkedListNode;
import quadtree.helpers.CollisionResult;

using quadtree.QuadTreeEx;
using quadtree.helpers.MathUtils;
using quadtree.extensions.PointEx;
using quadtree.extensions.CircleEx;
using quadtree.extensions.PolygonEx;
using quadtree.extensions.MovingPointEx;
using quadtree.extensions.RectangleEx;
using quadtree.extensions.MovingRectangleEx;

typedef OverlapProcessCallback = (CollisionResult) -> Bool;


class QuadTree
{
    public var maxDepth: Int = 5;
    public var objectsPerNode: Int = 4;

    var objects0: LinkedListNode<Collider>;
    var objects0Length: Int;
    var objects1: LinkedListNode<Collider>;
    var objects1Length: Int;
    var parent: QuadTree;
    var gjk: Gjk;
    var cache: QuadTreeCache;

    var topLeftTree: QuadTree;
    var topRightTree: QuadTree;
    var botLeftTree: QuadTree;
    var botRightTree: QuadTree;

    var topLeftBounds: BoundingBox;
    var topRightBounds: BoundingBox;
    var botLeftBounds: BoundingBox;
    var botRightBounds: BoundingBox;

    var leftEdge: Float;
    var topEdge: Float;
    var rightEdge: Float;
    var botEdge: Float;
    var halfWidth: Float;
    var halfHeight: Float;
    var midpointX: Float;
    var midpointY: Float;

    var useBothLists: Bool;
    var active: Bool;
    var hasSubdivided: Bool;

    var overlapProcessCallback: OverlapProcessCallback;


    public inline function new(x: Float, y: Float, width: Float, height: Float)
    {
        gjk = new Gjk();
        cache = new QuadTreeCache();
        reset(x, y, width, height);
    }


    /**
        Fully destroys the quad-tree, while maintaining the object instances so that they can be reused
        when `load()` is called again on the tree.

        @param x The new X-position of the tree. Default is it keeps its previous value.
        @param y The new Y-position of the tree. Default is it keeps its previous value.
        @param width The new width of the tree's bounds. Default is it keeps its previous value.
        @param height The new height of the tree's bounds. Default is it keeps its previous value.
    **/
    public function reset(?x: Float, ?y: Float, ?width: Float, ?height: Float)
    {
        active = true;
        hasSubdivided = false;
        useBothLists = false;

        cache.destroyLinkedList(objects0);
        objects0 = null;
        objects0Length = 0;
        cache.destroyLinkedList(objects1);
        objects1 = null;
        objects1Length = 0;

        if (topLeftTree != null)  topLeftTree.active = false;
        if (topRightTree != null) topRightTree.active = false;
        if (botLeftTree != null)  botLeftTree.active = false;
        if (botRightTree != null) botRightTree.active = false;

        // Apply defaults.
        x = x != null ? x : leftEdge;
        y = y != null ? y : topEdge;
        width = width != null ? width : rightEdge - x;
        height = height != null ? height : botEdge - x;

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
            cache.destroyBoundingBox(topLeftBounds);
            cache.destroyBoundingBox(topRightBounds);
            cache.destroyBoundingBox(botLeftBounds);
            cache.destroyBoundingBox(botRightBounds);
            topLeftBounds = cache.recycleBoundingBox(leftEdge, topEdge, halfWidth, halfHeight);
            topRightBounds = cache.recycleBoundingBox(midpointX, topEdge, halfWidth, halfHeight);
            botLeftBounds = cache.recycleBoundingBox(leftEdge, midpointY, halfWidth, halfHeight);
            botRightBounds = cache.recycleBoundingBox(midpointX, midpointY, halfWidth, halfHeight);
        }
    }


    /**
        Resets only the first group in the tree, removing the objects there from all nodes.
        Meant to be used when the intent is to compare multiple groups against the second
        without having to re-construct it.
    **/
    public function resetFirstGroup()
    {
        cache.destroyLinkedList(objects0);
        objects0 = null;
        objects0Length = 0;

        if (topLeftTree != null  && topLeftTree.active)     topLeftTree.resetFirstGroup();
        if (topRightTree != null && topRightTree.active)    topRightTree.resetFirstGroup();
        if (botLeftTree != null  && botLeftTree.active)     botLeftTree.resetFirstGroup();
        if (botRightTree != null && botRightTree.active)    botRightTree.resetFirstGroup();

        if (!topLeftTree.active && !topRightTree.active
         && !botLeftTree.active && !botRightTree.active
         && objects0Length == 0 && objects1Length == 0)
        {
            // This part of the tree is now empty.
            active = false;
        }
    }


    /**
        Load objects into the quad tree.

        On collisions, objects in `objectGroup` will have their `onOverlap()` method called before
        the respective object in `otherObjectGroup`. When not using the second list and collisions
        are only checked between objects in the first, `onOverlap()` will be called in an undefined order.

        Additionally, the underlying storage in the quadtree resembles a stack, so items that are later
        in the array will be processed first.

        @param objectGroup A list of objects that should be checked for collisions.
                           If `otherObjectGroup` is not provided, then objects in this group will
                           be checked against each other.
        @param otherObjectGroup An optional second group of objects to check for collisions
                                against the ones in `objectGroup`.
    **/
    public function load(objectGroup: Array<Collider>, ?otherObjectGroup: Array<Collider> = null)
    {
        useBothLists = useBothLists || (otherObjectGroup != null);

        if (objectGroup != null)
        {
            for (obj in objectGroup)
            {
                add(obj, 0);
            }
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
    public inline function setOverlapProcessCallback(overlapProcessCallback: OverlapProcessCallback)
    {
        this.overlapProcessCallback = overlapProcessCallback;
    }


    /**
        The quad tree's main method.
        Traverses the tree and checks for overlapping objects.
    **/
    public function execute()
    {
        if (hasSubdivided)
        {
            // Internal node, recursively check on children.

            if (subtreeActive(topLeftTree))
            {
                topLeftTree.execute();
            }
            if (subtreeActive(topRightTree))
            {
                topRightTree.execute();
            }
            if (subtreeActive(botLeftTree))
            {
                botLeftTree.execute();
            }
            if (subtreeActive(botRightTree))
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


    /**
        Removes the given object from the tree.

        @param object The object to remove.
    **/
    public function remove(object: Collider)
    {
        if (hasSubdivided)
        {
            // Is an internal node, forward the removal to the necessary subtrees.
            var quadrants: Quadrants = checkQuadrants(object);

            if ((quadrants & TopLeft) && subtreeActive(topLeftTree))
            {
                topLeftTree.remove(object);
            }
            if ((quadrants & TopRight) && subtreeActive(topRightTree))
            {
                topRightTree.remove(object);
            }
            if ((quadrants & BotLeft) && subtreeActive(botLeftTree))
            {
                botLeftTree.remove(object);
            }
            if ((quadrants & BotRight) && subtreeActive(botRightTree))
            {
                botRightTree.remove(object);
            }

            return;
        }

        var removeSuccessful: Bool = false;

        // Is a leaf node, remove the object from here.
        objects0 = removeFromGroup(objects0, object);
        if (objectRemoved_)
        {
            objects0Length--;
            removeSuccessful = true;
        }

        objects1 = removeFromGroup(objects1, object);
        if (objectRemoved_)
        {
            objects1Length--;
            removeSuccessful = true;
        }

        if (!removeSuccessful)
        {
            throw "Attempting to remove object not in the tree.";
        }
    }


    function add(object: Collider, group: Int = 0)
    {
        if (!hasSubdivided)
        {
            addHere(object, group);
            return;
        }

        var quadrants: Quadrants = checkQuadrants(object);

        if (quadrants & TopLeft)
        {
            addToTopLeft(object, group);
        }
        if (quadrants & TopRight)
        {
            addToTopRight(object, group);
        }
        if (quadrants & BotLeft)
        {
            addToBotLeft(object, group);
        }
        if (quadrants & BotRight)
        {
            addToBotRight(object, group);
        }
    }


    inline function removeFromGroup(objectList: LinkedListNode<Collider>, object: Collider): LinkedListNode<Collider>
    {
        objectRemoved_ = false;

        if (objectList == null) return null;

        if (objectList.item == object)
        {
            var tmp: LinkedListNode<Collider> = objectList.next;

            objectList.next = null;
            cache.destroyLinkedList(objectList);

            objectRemoved_ = true;
            return tmp;
        }

        var it: LinkedListNode<Collider> = objectList;
        var previous: LinkedListNode<Collider> = null;
        while (it != null)
        {
            if (it.item == object)
            {
                previous.next = it.next;

                it.next = null;
                cache.destroyLinkedList(it);

                objectRemoved_ = true;
                break;
            }

            previous = it;
            it = it.next;
        }

        return objectList;
    }


    inline function checkQuadrants(object: Collider): Quadrants
    {
        return switch object.areaType
        {
            case Point | MovingPoint:
                checkPointQuadrants(cast(object, Point));

            case Rectangle | MovingRectangle:
                checkRectangleQuadrants(cast(object, Rectangle));

            case Circle | MovingCircle:
                checkCircleQuadrants(cast(object, Circle));

            case Polygon | MovingPolygon:
                checkGenericQuadrants(cast(object, Polygon));

            case _:
                throw "Must specify an areaType";
        };
    }


    function checkRectangleQuadrants(rect: Rectangle)
    {
        if (rect.angle.isZero())
        {
            return checkRectBoundObjectQuadrants(rect, rect.x, rect.y, rect.x + rect.width, rect.y + rect.height);
        }
        else
        {
            return checkGenericQuadrants(rect);
        }
    }


    function checkPointQuadrants(point: Point): Quadrants
    {
        if (point.x < midpointX)
        {
            if (point.y < midpointY)
            {
                return TopLeft;
            }
            else
            {
                return BotLeft;
            }
        }
        else
        {
            if (point.y < midpointY)
            {
                return TopRight;
            }
            else
            {
                return BotRight;
            }
        }
    }


    function checkCircleQuadrants(circle: Circle): Quadrants
    {
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

        return checkRectBoundObjectQuadrants(circle, objLeftEdge, objTopEdge, objRightEdge, objBottomEdge);
    }


    function checkGenericQuadrants(collider: Collider): Quadrants
    {
        var quadrants: Quadrants = None;

        if (gjk.checkOverlap(topLeftBounds, collider))
        {
            quadrants |= TopLeft;
        }
        if (gjk.checkOverlap(topRightBounds, collider))
        {
            quadrants |= TopRight;
        }
        if (gjk.checkOverlap(botLeftBounds, collider))
        {
            quadrants |= BotLeft;
        }
        if (gjk.checkOverlap(botRightBounds, collider))
        {
            quadrants |= BotRight;
        }

        return quadrants;
    }


    @:generic
    function checkRectBoundObjectQuadrants<T: Collider>(object: T, objLeftEdge: Float, objTopEdge: Float, objRightEdge: Float, objBottomEdge: Float): Quadrants
    {
        // Check if the object fits completely inside one of the quadrants.
        if (objLeftEdge > leftEdge && objRightEdge < midpointX)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                return TopLeft;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                return BotLeft;
            }
        }
        if (objLeftEdge > midpointX && objRightEdge < rightEdge)
        {
            if (objTopEdge > topEdge && objBottomEdge < midpointY)
            {
                return TopRight;
            }
            if (objTopEdge > midpointY && objBottomEdge < botEdge)
            {
                return BotRight;
            }
        }

        // Object didn't completely fit in any quadrant, check for partial overlaps.
        var quadrants: Quadrants = None;
        if (this.intersectsTopLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            quadrants |= TopLeft;
        }
        if (this.intersectsTopRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            quadrants |= TopRight;
        }
        if (this.intersectsBotRight(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            quadrants |= BotRight;
        }
        if (this.intersectsBotLeft(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge))
        {
            quadrants |= BotLeft;
        }
        return quadrants;
    }


    function addHere(object: Collider, group: Int)
    {
        if (hasSubdivided)
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
                    objects0 = cache.recycleLinkedList(object, objects0);
                    objects0Length++;

                case 1:
                    objects1 = cache.recycleLinkedList(object, objects1);
                    objects1Length++;

                case _:
                    throw "Invalid group.";
            }

            if (shouldSubdivide())
            {
                subdivideTree();
            }
        }
    }


    function subdivideTree()
    {
        hasSubdivided = true;

        var it0: LinkedListNode<Collider> = objects0;
        while (it0 != null)
        {
            add(it0.item, 0);

            it0 = it0.next;
            objects0Length--;
        }

        var it1: LinkedListNode<Collider> = objects1;
        while (it1 != null)
        {
            add(it1.item, 1);

            it1 = it1.next;
            objects0Length--;
        }

        cache.destroyLinkedList(objects0);
        objects0 = null;
        cache.destroyLinkedList(objects1);
        objects1 = null;
    }


    function collisionCheckHere()
    {
        var objects0Iterator: LinkedListNode<Collider> = objects0;

        while (objects0Iterator != null)
        {
            var object: Collider = objects0Iterator.item;
            var listToCheck: LinkedListNode<Collider> = getListToCheck(objects0Iterator);

            objects0Iterator = objects0Iterator.next;

            if (listToCheck == null)
                continue;

            if (!object.collisionsEnabled)
                continue;

            switch object.areaType
            {
                case CollisionAreaType.Point:
                    collisionCheckPoint(cast(object, Point), listToCheck);

                case CollisionAreaType.MovingPoint:
                    collisionCheckMovingPoint(cast(object, MovingPoint), listToCheck);

                case CollisionAreaType.Rectangle:
                    collisionCheckRectangle(cast(object, Rectangle), listToCheck);

                case CollisionAreaType.MovingRectangle:
                    collisionCheckMovingRectangle(cast(object, MovingRectangle), listToCheck);

                // Handle all other cases with the GJK algorithm.
                case _:
                    collisionCheckGeneric(object, listToCheck);
            }
        }
    }


    function onDetectedCollision(obj1: Collider, obj2: Collider)
    {
        if (parent == null)
        {
            // Root node, process collision here.

            cache.collisionResult.set(obj1, obj2);
            if (overlapProcessCallback == null || overlapProcessCallback(cache.collisionResult))
            {
                obj1.onOverlap(obj2);
                obj2.onOverlap(obj1);
            }
        }
        else
        {
            // Leaf or internal node, process collision on the parent.

            parent.onDetectedCollision(obj1, obj2);
        }
    }


    inline function canSubdivide(): Bool
    {
        return maxDepth > 0;
    }


    inline function isLeafNode(): Bool
    {
        return !isInternalNode();
    }


    inline function isInternalNode(): Bool
    {
        return subtreeActive(topLeftTree)
            || subtreeActive(topRightTree)
            || subtreeActive(botLeftTree)
            || subtreeActive(botRightTree);
    }


    inline function shouldSubdivide(): Bool
    {
        return canSubdivide() && (objects0Length > objectsPerNode || objects1Length > objectsPerNode);
    }


    inline function isNodeEmpty(): Bool
    {
        return objects0Length == 0 && objects1Length == 0;
    }


    // =============================================================================
    //
    //                       TYPE-SPECIFIC COLLISION CHECKS
    //
    // =============================================================================

    function collisionCheckGeneric(collider: Collider, otherList: LinkedListNode<Collider>)
    {
        while (otherList != null)
        {
            var other: Collider = otherList.item;

            if (other.collisionsEnabled && gjk.checkOverlap(collider, other))
            {
                onDetectedCollision(collider, other);
            }

            otherList = otherList.next;
        }
    }


    function collisionCheckPoint(point: Point, otherList: LinkedListNode<Collider>)
    {
        while (otherList != null)
        {
            var other: Collider = otherList.item;

            if (other.collisionsEnabled && point.intersectsWith(other, gjk))
            {
                onDetectedCollision(point, other);
            }

            otherList = otherList.next;
        }
    }


    function collisionCheckMovingPoint(movingPoint: MovingPoint, otherList: LinkedListNode<Collider>)
    {
        while (otherList != null)
        {
            var other: Collider = otherList.item;

            if (other.collisionsEnabled && movingPoint.intersectsWith(other, gjk))
            {
                onDetectedCollision(movingPoint, other);
            }

            otherList = otherList.next;
        }
    }


    function collisionCheckRectangle(rect: Rectangle, otherList: LinkedListNode<Collider>)
    {
        while (otherList != null)
        {
            var other: Collider = otherList.item;

            if (other.collisionsEnabled && rect.intersectsWith(other, gjk))
            {
                onDetectedCollision(rect, other);
            }

            otherList = otherList.next;
        }
    }


    function collisionCheckMovingRectangle(rect: MovingRectangle, otherList: LinkedListNode<Collider>)
    {
        var hullX: Float = rect.hullX();
        var hullY: Float = rect.hullY();
        var hullWidth: Float = rect.hullWidth();
        var hullHeight: Float = rect.hullHeight();

        while (otherList != null)
        {
            var other: Collider = otherList.item;

            if (other.collisionsEnabled && MovingRectangleEx.intersectsWith(rect, hullX, hullY, hullWidth, hullHeight, other, gjk))
            {
                onDetectedCollision(rect, other);
            }

            otherList = otherList.next;
        }
    }


    // =============================================================================
    //
    //                             HELPER FUNCTIONS
    //
    // =============================================================================

    inline function getListToCheck(objectBeingChecked: LinkedListNode<Collider>): LinkedListNode<Collider>
    {
        return useBothLists ? objects1 : objectBeingChecked.next;
    }


    inline function addToTopLeft(collider: Collider, group: Int)
    {
        topLeftTree = validateSubtree(topLeftTree, topLeftBounds);
        topLeftTree.add(collider, group);
    }


    inline function addToTopRight(collider: Collider, group: Int)
    {
        topRightTree = validateSubtree(topRightTree, topRightBounds);
        topRightTree.add(collider, group);
    }


    inline function addToBotLeft(collider: Collider, group: Int)
    {
        botLeftTree = validateSubtree(botLeftTree, botLeftBounds);
        botLeftTree.add(collider, group);
    }


    inline function addToBotRight(collider: Collider, group: Int)
    {
        botRightTree = validateSubtree(botRightTree, botRightBounds);
        botRightTree.add(collider, group);
    }


    inline function validateSubtree(tree: QuadTree, bounds: BoundingBox): QuadTree
    {
        if (tree == null)
        {
            tree = new QuadTree(bounds.x, bounds.y, bounds.width, bounds.height);
            tree.parent = this;
            tree.maxDepth = maxDepth - 1;
            tree.gjk = gjk;
            tree.cache = cache;
            tree.useBothLists = useBothLists;
        }
        else if (!tree.active)
        {
            tree.reset(bounds.x, bounds.y, bounds.width, bounds.height);
            tree.useBothLists = useBothLists;
        }
        hasSubdivided = true;
        return tree;
    }


    inline function subtreeActive(tree: QuadTree): Bool
    {
        return tree != null && tree.active;
    }


    #if UNIT_TEST
    @IgnoreCover
    public function visualize(buf: StringBuf, space: String = "")
    {
        buf.add('${space}[$leftEdge, $topEdge, $rightEdge, $botEdge]\n');
        buf.add('${space}objects0: [${objects0 == null ? 0 : objects0.getLength()}]\n');
        buf.add('${space}objects1: [${objects1 == null ? 0 : objects1.getLength()}]\n');
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
    #end


    // =============================================================================
    //
    //                          HELPER VARIABLES FOR FUNCTION RESULTS
    //
    // =============================================================================

    @:noCompletion var objectRemoved_: Bool;
}

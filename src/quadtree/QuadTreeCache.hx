package quadtree;

import quadtree.helpers.CollisionResult;
import quadtree.types.Collider;
import quadtree.helpers.BoundingBox;
import quadtree.helpers.LinkedListNode;


/**
    Storage for objects and object pools, which should be shared by multiple
**/
class QuadTreeCache
{
    public var collisionResult: CollisionResult;

    var linkedListPool: LinkedListNode<Collider>;
    var boundingBoxPool: BoundingBox;


    public function new()
    {
        collisionResult = new CollisionResult();
        linkedListPool = null;
        boundingBoxPool = null;
    }


    public inline function recycleLinkedList(item: Collider, ?next: LinkedListNode<Collider>): LinkedListNode<Collider>
    {
        if (linkedListPool == null)
        {
            return new LinkedListNode<Collider>(item, next);
        }
        else
        {
            var list: LinkedListNode<Collider> = linkedListPool;
            linkedListPool = linkedListPool.next;

            list.item = item;
            list.next = next;
            return list;
        }
    }


    public inline function destroyLinkedList(list: LinkedListNode<Collider>)
    {
        while (list != null)
        {
            var next: LinkedListNode<Collider> = list.next;

            list.item = null;
            list.next = linkedListPool;
            linkedListPool = list;

            list = next;
        }
    }


    public inline function recycleBoundingBox(x: Float, y: Float, width: Float, height: Float): BoundingBox
    {
        if (boundingBoxPool == null)
        {
            return new BoundingBox(x, y, width, height);
        }
        else
        {
            var bounds: BoundingBox = boundingBoxPool;
            boundingBoxPool = boundingBoxPool.next;

            bounds.x = x;
            bounds.y = y;
            bounds.width = width;
            bounds.height = height;
            bounds.next = null;
            return bounds;
        }
    }


    public inline function destroyBoundingBox(bounds: BoundingBox)
    {
        if (bounds != null)
        {
            bounds.next = boundingBoxPool;
            boundingBoxPool = bounds;
        }
    }


    #if UNIT_TEST
    @IgnoreCover
    public inline function getLinkedListsCount(): Int
    {
        return linkedListPool != null ? linkedListPool.getLength() : 0;
    }
    #end
}

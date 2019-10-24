package quadtree;

import quadtree.types.Collider;
import quadtree.helpers.SubtreeBounds;
import quadtree.helpers.LinkedListNode;


class QuadTreeCache
{
    var linkedListPool: LinkedListNode<Collider>;
    var subtreeBoundsPool: SubtreeBounds;


    public function new() { }


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


    public inline function recycleSubtreeBounds(x: Float, y: Float, width: Float, height: Float): SubtreeBounds
    {
        if (subtreeBoundsPool == null)
        {
            return new SubtreeBounds(x, y, width, height);
        }
        else
        {
            var bounds: SubtreeBounds = subtreeBoundsPool;
            subtreeBoundsPool = subtreeBoundsPool.next;

            bounds.x = x;
            bounds.y = y;
            bounds.width = width;
            bounds.height = height;
            bounds.next = null;
            return bounds;
        }
    }


    public inline function destroySubtreeBounds(bounds: SubtreeBounds)
    {
        if (bounds != null)
        {
            bounds.next = subtreeBoundsPool;
            subtreeBoundsPool = bounds;
        }
    }


    @IgnoreCover
    public inline function getLinkedListsCount(): Int
    {
        return linkedListPool != null ? linkedListPool.getLength() : 0;
    }
}

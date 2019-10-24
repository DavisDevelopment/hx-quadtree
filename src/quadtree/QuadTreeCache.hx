package quadtree;

import quadtree.types.Collider;


class QuadTreeCache
{
    var linkedListPool: LinkedListNode<Collider>;


    public function new()
    {

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


    @IgnoreCover
    public inline function getLinkedListsCount(): Int
    {
        return linkedListPool != null ? linkedListPool.getLength() : 0;
    }
}

package quadtree.helpers;


class LinkedListNode<T>
{
    public var item: T;
    public var next: LinkedListNode<T>;

    
    public function new(item: T, ?next: LinkedListNode<T>)
    {
        this.item = item;
        this.next = next;
    }


    #if UNIT_TEST
    @IgnoreCover
    public function getLength(): Int
    {
        return 1 + (next != null ? next.getLength() : 0);
    }


    @IgnoreCover
    public function get(index: Int): T
    {
        if (index == getLength() - 1)
        {
            return item;
        }
        else if (index > getLength() - 1)
        {
            return null;
        }
        else
        {
            return next.get(index);
        }
    }
    #end
}

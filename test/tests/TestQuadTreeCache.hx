package tests;

import utest.Assert;
import utest.ITest;
import quadtree.QuadTreeCache;


class TestQuadTreeCache extends QuadTreeCache implements ITest
{
    public function new() { super(); }


    function testLinkedLists()
    {
        Assert.equals(0, getLinkedListsCount());

        var list1 = recycleLinkedList(null, null);
        var list2 = recycleLinkedList(null, null);
        
        Assert.equals(0, getLinkedListsCount());

        destroyLinkedList(list1);
        
        Assert.equals(1, getLinkedListsCount());

        destroyLinkedList(list2);
        
        Assert.equals(2, getLinkedListsCount());

        var list2r = recycleLinkedList(null, null);
        
        Assert.equals(1, getLinkedListsCount());
        
        var list1r = recycleLinkedList(null, null);
        
        Assert.equals(0, getLinkedListsCount());
        Assert.equals(list1, list1r);
        Assert.equals(list2, list2r);
    }
}

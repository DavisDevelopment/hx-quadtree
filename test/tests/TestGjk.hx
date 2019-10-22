package tests;

import utest.Assert;
import quadtree.gjk.Gjk;
import utest.ITest;
import tests.models.Triangle;


class TestGjk implements ITest
{
    var gjk: Gjk;


    public function new() { }


    public function setupClass()
    {
        gjk = new Gjk();
    }


    function testTriangles()
    {
        var t1: Triangle = new Triangle([0, 0], [0, 1], [1, 0]);
        var t2: Triangle = new Triangle([0, 0], [1, 1], [1, 0]);

        Assert.isTrue(gjk.checkOverlap(t1, t2));
    }
}

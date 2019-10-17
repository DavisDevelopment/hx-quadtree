package tests;

import utest.Assert;
import utest.ITest;
import quadtree.types.Rectangle;
import quadtree.QuadTree;
import quadtree.CollisionAreaType;
import tests.models.Point;
import tests.models.BoundingBox;

using quadtree.QuadTreeEx;


class TestQuadTreeExecute extends QuadTree implements ITest
{
    public function new()
    {
        super(0, 0, 0, 0, 0);
    }


    function setup()
    {
        reset(0, 0, 1000, 1000, 5);

        Assert.isNull(topLeftTree);
        Assert.isNull(topRightTree);
        Assert.isNull(botLeftTree);
        Assert.isNull(botRightTree);
    }


    
}

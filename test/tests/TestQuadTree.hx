package tests;

import utest.Assert;
import tests.models.BoundingBox;
import quadtree.Area;
import quadtree.QuadTree;
import utest.ITest;

using quadtree.QuadTreeEx;


class TestQuadTree extends QuadTree implements ITest
{
    public function new()
    {
        super(0, 0, 0, 0, 0);
    }


    function setup()
    {
        reset(0, 0, 1000, 1000, 5);
    }


    function testAddToQuadrants()
    {
        var area: Area = new BoundingBox(0, 0, 1000, 1000);

        Assert.isNull(topLeftTree);
        Assert.isNull(topRightTree);
        Assert.isNull(botLeftTree);
        Assert.isNull(botRightTree);

        addToTopLeft(area);
        Assert.equals(0, topLeftTree.leftEdge);
        Assert.equals(0, topLeftTree.topEdge);
        Assert.equals(500, topLeftTree.rightEdge);
        Assert.equals(500, topLeftTree.botEdge);
        Assert.notNull(topLeftTree);
        Assert.equals(4, topLeftTree.maxDepth);
        Assert.equals(1, topLeftTree.objects0.length);

        addToTopRight(area);
        Assert.equals(500, topRightTree.leftEdge);
        Assert.equals(0, topRightTree.topEdge);
        Assert.equals(1000, topRightTree.rightEdge);
        Assert.equals(500, topRightTree.botEdge);
        Assert.notNull(topRightTree);
        Assert.equals(4, topRightTree.maxDepth);
        Assert.equals(1, topRightTree.objects0.length);

        addToBotLeft(area);
        Assert.equals(0, botLeftTree.leftEdge);
        Assert.equals(500, botLeftTree.topEdge);
        Assert.equals(500, botLeftTree.rightEdge);
        Assert.equals(1000, botLeftTree.botEdge);
        Assert.notNull(botLeftTree);
        Assert.equals(4, botLeftTree.maxDepth);
        Assert.equals(1, botLeftTree.objects0.length);

        addToBotRight(area);
        Assert.equals(500, botRightTree.leftEdge);
        Assert.equals(500, botRightTree.topEdge);
        Assert.equals(1000, botRightTree.rightEdge);
        Assert.equals(1000, botRightTree.botEdge);
        Assert.notNull(botRightTree);
        Assert.equals(4, botRightTree.maxDepth);
        Assert.equals(1, botRightTree.objects0.length);
    }


    function testAddToTopLeft()
    {
        var area: Area = new BoundingBox(10, 10, 10, 10);

        add(area);

        // Should not have been added here.
        Assert.equals(0, objects0.length);
        Assert.equals(0, objects1.length);

        Assert.notNull(topLeftTree);
        Assert.isNull(topRightTree);
        Assert.isNull(botLeftTree);
        Assert.isNull(botRightTree);

        // Recursively find the added area,
        // it should be on the topleft quadrant
        // down to the max depth.
        var cur: QuadTree = this;
        var foundArea: Bool = false;
        do
        {
            cur = cur.topLeftTree;

            if (cur.maxDepth == 0)
            {
                foundArea = cur.objects0[0] == area;
            }
        }
        while (cur.topLeftTree != null);

        Assert.isTrue(foundArea);
    }
}

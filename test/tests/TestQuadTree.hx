package tests;

import quadtree.Point;
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

        Assert.isNull(topLeftTree);
        Assert.isNull(topRightTree);
        Assert.isNull(botLeftTree);
        Assert.isNull(botRightTree);
    }


    function testAddToWrongList()
    {
        var area: Area = new BoundingBox(0, 0, 1000, 1000);

        Assert.raises(() -> addToList(area, -1), String);
    }


    function testCreateQuadrants()
    {
        maxDepth = 5;

        var area: Area = new BoundingBox(0, 0, 1000, 1000);

        addToTopLeft(area);
        addToTopLeft(area);
        Assert.equals(0, topLeftTree.leftEdge);
        Assert.equals(0, topLeftTree.topEdge);
        Assert.equals(500, topLeftTree.rightEdge);
        Assert.equals(500, topLeftTree.botEdge);
        Assert.notNull(topLeftTree);
        Assert.equals(4, topLeftTree.maxDepth);
        Assert.equals(2, topLeftTree.objects0.length);

        addToTopRight(area);
        addToTopRight(area, 1);
        Assert.equals(500, topRightTree.leftEdge);
        Assert.equals(0, topRightTree.topEdge);
        Assert.equals(1000, topRightTree.rightEdge);
        Assert.equals(500, topRightTree.botEdge);
        Assert.notNull(topRightTree);
        Assert.equals(4, topRightTree.maxDepth);
        Assert.equals(1, topRightTree.objects0.length);
        Assert.equals(1, topRightTree.objects1.length);

        addToBotLeft(area);
        addToBotLeft(area);
        Assert.equals(0, botLeftTree.leftEdge);
        Assert.equals(500, botLeftTree.topEdge);
        Assert.equals(500, botLeftTree.rightEdge);
        Assert.equals(1000, botLeftTree.botEdge);
        Assert.notNull(botLeftTree);
        Assert.equals(4, botLeftTree.maxDepth);
        Assert.equals(2, botLeftTree.objects0.length);

        addToBotRight(area);
        addToBotRight(area);
        Assert.equals(500, botRightTree.leftEdge);
        Assert.equals(500, botRightTree.topEdge);
        Assert.equals(1000, botRightTree.rightEdge);
        Assert.equals(1000, botRightTree.botEdge);
        Assert.notNull(botRightTree);
        Assert.equals(4, botRightTree.maxDepth);
        Assert.equals(2, botRightTree.objects0.length);
    }


    function testAddToQuadrants()
    {
        var topRight: Area = new BoundingBox(990, 10, 9, 9);
        add(topRight);
        Assert.notNull(topRightTree);
        Assert.equals(topRight, traverseTree(qt -> qt.topRightTree));

        var topLeft: Area = new BoundingBox(10, 10, 9, 9);
        add(topLeft);
        Assert.notNull(topLeftTree);
        Assert.equals(topLeft, traverseTree(qt -> qt.topLeftTree));
        
        var botLeft: Area = new BoundingBox(10, 990, 9, 9);
        add(botLeft);
        Assert.notNull(botLeftTree);
        Assert.equals(botLeft, traverseTree(qt -> qt.botLeftTree));
        
        var botRight: Area = new BoundingBox(990, 990, 9, 9);
        add(botRight);
        Assert.notNull(botRightTree);
        Assert.equals(botRight, traverseTree(qt -> qt.botRightTree));

        // Should not have been added here.
        Assert.equals(0, objects0.length);
        Assert.equals(0, objects1.length);
    }


    function testAddOverlapAll()
    {
        maxDepth = 2;

        var area: Area = new BoundingBox(1, 1, 998, 998);

        Assert.isTrue(this.intersectsTopLeft(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isTrue(this.intersectsTopRight(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isTrue(this.intersectsBotLeft(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isTrue(this.intersectsBotRight(area.x, area.y, area.x + area.width, area.y + area.height));

        add(area);

        Assert.isFalse(topLeftTree.isContainedInArea(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isFalse(topRightTree.isContainedInArea(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isFalse(botLeftTree.isContainedInArea(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isFalse(botRightTree.isContainedInArea(area.x, area.y, area.x + area.width, area.y + area.height));


        var timesChecked: Int = 0;

        var check = function(qt: QuadTree)
        {
            Assert.equals(area, qt.objects0[0]);
            timesChecked++;
        };

        traverseAllRecursive(this, check);
        trace(timesChecked);
    }


    function traverseTree(next: QuadTree->QuadTree, index: Int = 0): Point
    {
        var cur: QuadTree = this;
        do
        {
            cur = next(cur);

            if (cur.maxDepth == 0)
            {
                return cur.objects0[index];
            }
        }
        while (next(cur) != null);

        return null;
    }


    static function traverseAllRecursive(cur: QuadTree, check: QuadTree->Void)
    {
        if (cur.maxDepth == 0)
        {
            check(cur);
        }
        else
        {
            Assert.notNull(cur.topLeftTree);
            Assert.notNull(cur.topRightTree);
            Assert.notNull(cur.botLeftTree);
            Assert.notNull(cur.botRightTree);
            traverseAllRecursive(cur.topLeftTree, check);
            traverseAllRecursive(cur.topRightTree, check);
            traverseAllRecursive(cur.botLeftTree, check);
            traverseAllRecursive(cur.botRightTree, check);
        }
    }


    function debugPrintTree()
    {
        var buf: StringBuf = new StringBuf();
        visualize(buf);
        Sys.println(buf.toString());
    }
}

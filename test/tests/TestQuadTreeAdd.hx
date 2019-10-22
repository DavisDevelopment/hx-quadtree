package tests;

import quadtree.types.Collider;
import utest.Assert;
import utest.ITest;
import quadtree.types.Rectangle;
import quadtree.QuadTree;
import quadtree.CollisionAreaType;
import tests.models.Point;
import tests.models.Box;

using quadtree.QuadTreeEx;


class TestQuadTreeAdd extends QuadTree implements ITest
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


    function testAddHere()
    {
        maxDepth = 0;
        var area: Box = new Box(0, 0, 1000, 1000);
        addHere(area, 0);
        addHere(area, 1);

        Assert.equals(area, objects0[0]);
        Assert.equals(area, objects1[0]);
    }


    function testAddToWrongList()
    {
        var area: Rectangle = new Box(0, 0, 1000, 1000);

        Assert.raises(() -> addHere(area, -1), String);
    }


    function testAddInvalidAreaType()
    {
        var area: Box = new Box(0, 0, 1000, 1000);
        area.areaType = cast(-1, CollisionAreaType);

        Assert.raises(() -> add(area, 0), String);
    }


    function testCreateQuadrants()
    {
        maxDepth = 5;

        var area: Box = new Box(0, 0, 1000, 1000);

        addToTopLeft(area);
        Assert.equals(0, topLeftTree.leftEdge);
        Assert.equals(0, topLeftTree.topEdge);
        Assert.equals(500, topLeftTree.rightEdge);
        Assert.equals(500, topLeftTree.botEdge);
        Assert.notNull(topLeftTree);
        Assert.equals(4, topLeftTree.maxDepth);

        addToTopRight(area);
        Assert.equals(500, topRightTree.leftEdge);
        Assert.equals(0, topRightTree.topEdge);
        Assert.equals(1000, topRightTree.rightEdge);
        Assert.equals(500, topRightTree.botEdge);
        Assert.notNull(topRightTree);
        Assert.equals(4, topRightTree.maxDepth);

        addToBotLeft(area);
        Assert.equals(0, botLeftTree.leftEdge);
        Assert.equals(500, botLeftTree.topEdge);
        Assert.equals(500, botLeftTree.rightEdge);
        Assert.equals(1000, botLeftTree.botEdge);
        Assert.notNull(botLeftTree);
        Assert.equals(4, botLeftTree.maxDepth);

        addToBotRight(area);
        Assert.equals(500, botRightTree.leftEdge);
        Assert.equals(500, botRightTree.topEdge);
        Assert.equals(1000, botRightTree.rightEdge);
        Assert.equals(1000, botRightTree.botEdge);
        Assert.notNull(botRightTree);
        Assert.equals(4, botRightTree.maxDepth);
    }


    function testAddToQuadrants()
    {
        var topRight: Box = new Box(990, 10, 9, 9);
        var topRight2: Box = new Box(990, 10, 9, 9);
        load([topRight, topRight2]);
        Assert.notNull(topRightTree);
        Assert.equals(topRight, traverseTree(qt -> qt.topRightTree));
        Assert.equals(topRight2, traverseTree(qt -> qt.topRightTree, 1));

        var topLeft: Box = new Box(10, 10, 9, 9);
        var topLeft2: Box = new Box(10, 10, 9, 9);
        load([topLeft, topLeft2]);
        Assert.notNull(topLeftTree);
        Assert.equals(topLeft, traverseTree(qt -> qt.topLeftTree));
        Assert.equals(topLeft2, traverseTree(qt -> qt.topLeftTree, 1));
        
        var botLeft: Box = new Box(10, 990, 9, 9);
        var botLeft2: Box = new Box(10, 990, 9, 9);
        load([botLeft, botLeft2]);
        Assert.notNull(botLeftTree);
        Assert.equals(botLeft, traverseTree(qt -> qt.botLeftTree));
        Assert.equals(botLeft2, traverseTree(qt -> qt.botLeftTree, 1));
        
        var botRight: Box = new Box(990, 990, 9, 9);
        var botRight2: Box = new Box(990, 990, 9, 10);
        load([], [botRight, botRight2]);
        Assert.notNull(botRightTree);
        Assert.equals(botRight, traverseTree(qt -> qt.botRightTree, qt -> qt.objects1));
        Assert.equals(botRight2, traverseTree(qt -> qt.botRightTree, qt -> qt.objects1, 1));

        // Should not have been added here.
        Assert.equals(0, objects0.length);
        Assert.equals(0, objects1.length);
    }


    function testAddOverlapAll()
    {
        maxDepth = 2;

        var area: Box = new Box(1, 1, 998, 998);

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
        
        Assert.equals(16, timesChecked);
    }


    function testAddPoint()
    {
        var topRight: Point = new Point(990, 10);
        add(topRight);
        Assert.notNull(topRightTree);
        Assert.equals(topRight, traverseTree(qt -> qt.topRightTree));

        var topLeft: Point = new Point(10, 10);
        add(topLeft);
        Assert.notNull(topLeftTree);
        Assert.equals(topLeft, traverseTree(qt -> qt.topLeftTree));
        
        var botLeft: Point = new Point(10, 990);
        add(botLeft);
        Assert.notNull(botLeftTree);
        Assert.equals(botLeft, traverseTree(qt -> qt.botLeftTree));
        
        var botRight: Point = new Point(990, 990);
        add(botRight);
        Assert.notNull(botRightTree);
        Assert.equals(botRight, traverseTree(qt -> qt.botRightTree));

        // Should not have been added here.
        Assert.equals(0, objects0.length);
        Assert.equals(0, objects1.length);
    }


    function traverseTree(next: QuadTree->QuadTree, ?objList: QuadTree->Array<Collider> = null, ?index: Int = 0): Collider
    {
        var cur: QuadTree = this;
        do
        {
            cur = next(cur);

            if (cur.maxDepth == 0)
            {
                return objList == null ? cur.objects0[index] : objList(cur)[index];
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
        trace(buf.toString());
    }
}

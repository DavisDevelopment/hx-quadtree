package tests;

import quadtree.helpers.LinkedListNode;
import tests.models.Triangle;
import quadtree.types.Collider;
import utest.Assert;
import utest.ITest;
import quadtree.types.Rectangle;
import quadtree.QuadTree;
import quadtree.CollisionAreaType;
import tests.models.Point;
import tests.models.Box;
import tests.models.Circle;

using quadtree.QuadTreeEx;


class TestQuadTreeAdd extends QuadTree implements ITest
{
    public function new()
    {
        super(0, 0, 0, 0);
    }


    function setup()
    {
        reset(0, 0, 1000, 1000);
        maxDepth = 5;

        Assert.isFalse(subtreeActive(topLeftTree));
        Assert.isFalse(subtreeActive(topRightTree));
        Assert.isFalse(subtreeActive(botLeftTree));
        Assert.isFalse(subtreeActive(botRightTree));
    }


    function testAddHere()
    {
        maxDepth = 0;
        var area: Box = new Box(0, 0, 1000, 1000);
        addHere(area, 0);
        addHere(area, 1);

        Assert.equals(area, objects0.get(0));
        Assert.equals(area, objects1.get(0));
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

        add(area, 0);
        add(area, 0);
        add(area, 0);
        add(area, 0);

        Assert.raises(() -> add(area, 0), String);
    }


    function testCreateQuadrants()
    {
        maxDepth = 5;

        Assert.isFalse(isInternalNode());

        var area: Box = new Box(0, 0, 1000, 1000);

        addToTopLeft(area, 0);
        Assert.equals(0, topLeftTree.leftEdge);
        Assert.equals(0, topLeftTree.topEdge);
        Assert.equals(500, topLeftTree.rightEdge);
        Assert.equals(500, topLeftTree.botEdge);
        Assert.notNull(topLeftTree);
        Assert.equals(4, topLeftTree.maxDepth);

        addToTopRight(area, 0);
        Assert.equals(500, topRightTree.leftEdge);
        Assert.equals(0, topRightTree.topEdge);
        Assert.equals(1000, topRightTree.rightEdge);
        Assert.equals(500, topRightTree.botEdge);
        Assert.notNull(topRightTree);
        Assert.equals(4, topRightTree.maxDepth);

        addToBotLeft(area, 0);
        Assert.equals(0, botLeftTree.leftEdge);
        Assert.equals(500, botLeftTree.topEdge);
        Assert.equals(500, botLeftTree.rightEdge);
        Assert.equals(1000, botLeftTree.botEdge);
        Assert.notNull(botLeftTree);
        Assert.equals(4, botLeftTree.maxDepth);

        addToBotRight(area, 0);
        Assert.equals(500, botRightTree.leftEdge);
        Assert.equals(500, botRightTree.topEdge);
        Assert.equals(1000, botRightTree.rightEdge);
        Assert.equals(1000, botRightTree.botEdge);
        Assert.notNull(botRightTree);
        Assert.equals(4, botRightTree.maxDepth);

        Assert.isTrue(isInternalNode());
        Assert.isTrue(isNodeEmpty());
    }


    function testAddToQuadrants()
    {
        hasSubdivided = true;

        var topRight: Box = new Box(990, 10, 9, 9);
        var topRight2: Box = new Box(990, 10, 9, 9);
        load([topRight, topRight2]);
        Assert.equals(topRight, traverseTree(qt -> qt.topRightTree));
        Assert.equals(topRight2, traverseTree(qt -> qt.topRightTree, 1));

        var topLeft: Box = new Box(10, 10, 9, 9);
        var topLeft2: Box = new Box(10, 10, 9, 9);
        load([topLeft, topLeft2]);
        Assert.equals(topLeft, traverseTree(qt -> qt.topLeftTree));
        Assert.equals(topLeft2, traverseTree(qt -> qt.topLeftTree, 1));
        
        var botLeft: Box = new Box(10, 990, 9, 9);
        var botLeft2: Box = new Box(10, 990, 9, 9);
        load([botLeft, botLeft2]);
        Assert.equals(botLeft, traverseTree(qt -> qt.botLeftTree));
        Assert.equals(botLeft2, traverseTree(qt -> qt.botLeftTree, 1));
        
        var botRight: Box = new Box(990, 990, 9, 9);
        var botRight2: Box = new Box(990, 990, 9, 10);
        load([], [botRight, botRight2]);
        Assert.equals(botRight, traverseTree(qt -> qt.botRightTree, qt -> qt.objects1));
        Assert.equals(botRight2, traverseTree(qt -> qt.botRightTree, qt -> qt.objects1, 1));
    }


    function testAddOverlapAll()
    {
        hasSubdivided = true;
        maxDepth = 1;

        var area: Box = new Box(1, 1, 998, 998);

        Assert.isTrue(this.intersectsTopLeft(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isTrue(this.intersectsTopRight(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isTrue(this.intersectsBotLeft(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isTrue(this.intersectsBotRight(area.x, area.y, area.x + area.width, area.y + area.height));

        addHere(area, 0);

        Assert.isFalse(topLeftTree.isContainedInArea(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isFalse(topRightTree.isContainedInArea(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isFalse(botLeftTree.isContainedInArea(area.x, area.y, area.x + area.width, area.y + area.height));
        Assert.isFalse(botRightTree.isContainedInArea(area.x, area.y, area.x + area.width, area.y + area.height));


        var timesChecked: Int = 0;

        var check = function(qt: QuadTree)
        {
            Assert.equals(area, qt.objects0.get(0));
            timesChecked++;
        };

        traverseAllRecursive(this, check);
        
        Assert.equals(4, timesChecked);
    }


    function testAddPoint()
    {
        hasSubdivided = true;

        var topRight: Point = new Point(990, 10);
        add(topRight);
        Assert.equals(topRight, topRightTree.objects0.get(0));

        var topLeft: Point = new Point(10, 10);
        add(topLeft);
        Assert.equals(topLeft, topLeftTree.objects0.get(0));
        
        var botLeft: Point = new Point(10, 990);
        add(botLeft);
        Assert.equals(botLeft, botLeftTree.objects0.get(0));
        
        var botRight: Point = new Point(990, 990);
        add(botRight);
        Assert.equals(botRight, botRightTree.objects0.get(0));
    }


    function testAddTriangle()
    {
        hasSubdivided = true;

        var topRight: Triangle = new Triangle([990, 10], [990, 11], [991, 10]);
        add(topRight);
        Assert.equals(topRight, topRightTree.objects0.get(0));

        var topLeft: Triangle = new Triangle([10, 10], [11, 10], [10, 11]);
        add(topLeft);
        Assert.equals(topLeft, topLeftTree.objects0.get(0));
        
        var botLeft: Triangle = new Triangle([10, 990], [11, 990], [10, 991]);
        add(botLeft);
        Assert.equals(botLeft, botLeftTree.objects0.get(0));
        
        var botRight: Triangle = new Triangle([990, 990], [991, 990], [990, 991]);
        add(botRight);
        Assert.equals(botRight, botRightTree.objects0.get(0));
    }


    function testAddCircle()
    {
        hasSubdivided = true;
        
        var topRight: Circle = new Circle(990, 10, 2);
        add(topRight);
        Assert.equals(topRight, traverseTree(qt -> qt.topRightTree));

        var topLeft: Circle = new Circle(10, 10, 2);
        add(topLeft);
        Assert.equals(topLeft, traverseTree(qt -> qt.topLeftTree));
        
        var botLeft: Circle = new Circle(0, 1000, 6);
        add(botLeft);
        Assert.equals(botLeft, traverseTree(qt -> qt.botLeftTree));
        
        var botRight: Circle = new Circle(990, 990, 2);
        add(botRight);
        Assert.equals(botRight, traverseTree(qt -> qt.botRightTree));
    }


    function traverseTree(next: QuadTree->QuadTree, ?objList: QuadTree->LinkedListNode<Collider> = null, ?index: Int = 0): Collider
    {
        var cur: QuadTree = this;
        do
        {
            if (cur.maxDepth == 0 || cur.isLeafNode())
            {
                return objList == null ? cur.objects0.get(index) : objList(cur).get(index);
            }

            cur = next(cur);
        }
        while (subtreeActive(cur));

        return null;
    }


    static function traverseAllRecursive(cur: QuadTree, check: QuadTree->Void)
    {
        if (cur.maxDepth == 0 || cur.isLeafNode())
        {
            check(cur);
        }
        else
        {
            if (cur.subtreeActive(cur.topLeftTree))
                traverseAllRecursive(cur.topLeftTree, check);
            if (cur.subtreeActive(cur.topRightTree))
                traverseAllRecursive(cur.topRightTree, check);
            if (cur.subtreeActive(cur.botLeftTree))
                traverseAllRecursive(cur.botLeftTree, check);
            if (cur.subtreeActive(cur.botRightTree))
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

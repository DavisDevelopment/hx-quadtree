package tests;

import utest.Assert;
import utest.ITest;
import quadtree.types.Rectangle;
import quadtree.QuadTree;
import quadtree.CollisionAreaType;
import tests.models.Point;
import tests.models.Box;
import tests.models.MovingBox;
import tests.models.MovingPoint;

using quadtree.QuadTreeEx;


class TestQuadTreeExecute extends QuadTree implements ITest
{
    public function new()
    {
        super(0, 0, 1000, 1000, 5);
    }


    function setup()
    {
        reset();
        setOverlapProcessCallback(null);

        Assert.isNull(topLeftTree);
        Assert.isNull(topRightTree);
        Assert.isNull(botLeftTree);
        Assert.isNull(botRightTree);
    }


    function testCollisionWithSelfSmall()
    {
        var box: Box = new Box(150, 150, 1, 1);
        load([box, box], [box]);

        var timesCalled: Int = 0;

        setOverlapProcessCallback((b1, b2) -> {

            Assert.equals(box, b1);
            Assert.equals(box, b2);

            timesCalled++;

            return true;
        });

        execute();

        Assert.equals(2, timesCalled);
        Assert.isTrue(box.collisionsDetected > 0);
    }


    function testCollisionProcessingReturnFalse()
    {
        var box: Box = new Box(150, 150, 1, 1);
        load([box], [box]);

        setOverlapProcessCallback((b1, b2) -> {

            return false;
        });

        execute();
        
        Assert.equals(0, box.collisionsDetected);
    }


    function testNoCollisions()
    {
        var b1: Box = new Box(1, 1, 1, 1);
        var b2: Box = new Box(990, 1, 1, 1);
        var b3: Box = new Box(1, 990, 1, 1);
        var b4: Box = new Box(990, 990, 1, 1);
        load([b1, b2, b3, b4]);

        execute();

        Assert.equals(0, b1.collisionsDetected);
        Assert.equals(0, b2.collisionsDetected);
        Assert.equals(0, b3.collisionsDetected);
        Assert.equals(0, b4.collisionsDetected);
    }


    function testCollisionPointInRectangle()
    {
        var b1: Box = new Box(100, 100, 100, 100);
        var p1: Point = new Point(150, 150);
        var p2: Point = new Point(300, 300);
        var p3: MovingPoint = new MovingPoint(0, 0);
        p3.moveTo(150, 150);
        var p4: MovingPoint = new MovingPoint(101, 101);
        p4.moveTo(99, 99);

        load([p3, b1, p2, p1, p4]);

        execute();

        Assert.equals(1, p1.collisionsDetected);
        Assert.equals(0, p2.collisionsDetected);
        Assert.equals(1, p3.collisionsDetected);
        Assert.equals(1, p4.collisionsDetected);
        Assert.equals(3, b1.collisionsDetected);
    }


    function testMovingRectangleCollisions()
    {
        var b1: MovingBox = new MovingBox(100, 100, 100, 100);

    }


    function debugPrintTree()
    {
        var buf: StringBuf = new StringBuf();
        visualize(buf);
        Sys.println(buf.toString());
    }
}

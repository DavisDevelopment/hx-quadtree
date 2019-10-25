package tests;

import quadtree.helpers.MathUtils;
import tests.models.Circle;
import tests.models.Triangle;
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
        super(0, 0, 1000, 1000);
        maxDepth = 5;
    }


    function setup()
    {
        reset();
        setOverlapProcessCallback(null);

        Assert.isFalse(subtreeActive(topLeftTree));
        Assert.isFalse(subtreeActive(topRightTree));
        Assert.isFalse(subtreeActive(botLeftTree));
        Assert.isFalse(subtreeActive(botRightTree));
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

        execute();

        Assert.equals(4, timesCalled);
        Assert.isTrue(box.collisionsDetected > 0);

        // Disable collisions.
        var curCollisions: Int = box.collisionsDetected;
        box.collisionsEnabled = false;

        execute();
        Assert.equals(4, timesCalled);
        Assert.equals(curCollisions, box.collisionsDetected);
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


    function testRotatedRectangle()
    {
        hasSubdivided = true;

        var b1: Box = new Box(0, 0, 100, 10);
        var b2: Box = new Box(0, 30, 100, 10);

        load([b1, b2]);

        execute();

        // Normally, they should not intersect.
        Assert.equals(0, b1.collisionsDetected);
        Assert.equals(0, b2.collisionsDetected);

        b1.angle = 90;

        reset();
        hasSubdivided = true;

        load([b1, b2]);

        execute();
        
        // Now it should have intersected.
        Assert.equals(1, b1.collisionsDetected);
        Assert.equals(1, b2.collisionsDetected);

        b1.angle = 180;

        reset();
        hasSubdivided = true;

        load([b1, b2]);

        execute();
        
        // Now it should not have intersected again.
        Assert.equals(1, b1.collisionsDetected);
        Assert.equals(1, b2.collisionsDetected);
    }


    function testCollisionPointInRectangle()
    {
        var b1: MovingBox = new MovingBox(103, 103, 1, 1);
        var b2: Box = new Box(100, 100, 100, 100);
        var p1: Point = new Point(150, 150);
        var p2: Point = new Point(300, 300);
        var p3: MovingPoint = new MovingPoint(0, 0);
        p3.moveTo(150, 150);
        var p4: MovingPoint = new MovingPoint(101, 101);
        p4.moveTo(99, 99);
        var p5: Point = new Point(99, 99);
        var p6: Point = new Point(101, 101);
        var p7: MovingPoint = new MovingPoint(99, 99);
        var p8: MovingPoint = new MovingPoint(399, 399);
        var p9: MovingPoint = new MovingPoint(399, 399);
        p9.moveTo(405, 405);
        var p10: Point = new Point(408, 408);
        var b3: MovingBox = new MovingBox(400, 400, 100, 100);
        var c1: Circle = new Circle(408, 408, 0.5);

        load(reverse([b1, p5, p6, p3, b2, p2, p1, p4, p10, b3, p7, p8, p9, c1]));

        execute();

        Assert.equals(1, p1.collisionsDetected);
        Assert.equals(0, p2.collisionsDetected);
        Assert.equals(1, p3.collisionsDetected);
        Assert.equals(1, p4.collisionsDetected);
        Assert.equals(0, p5.collisionsDetected);
        Assert.equals(1, p6.collisionsDetected);
        Assert.equals(0, p7.collisionsDetected);
        Assert.equals(0, p8.collisionsDetected);
        Assert.equals(1, p9.collisionsDetected);
        Assert.equals(2, p10.collisionsDetected);
        Assert.equals(1, b1.collisionsDetected);
        Assert.equals(5, b2.collisionsDetected);
        Assert.equals(3, b3.collisionsDetected);
        Assert.equals(2, c1.collisionsDetected);
    }


    function testMovingRectangleCollisions()
    {
        var b1: MovingBox = new MovingBox(100, 100, 100, 100);
        b1.angle = 180 * MathUtils.TO_RAD;
        var b2: MovingBox = new MovingBox(190, 190, 10, 10);
        b2.moveTo(200, 200);
        var b3: MovingBox = new MovingBox(201, 201, 99, 99);
        var p1: MovingPoint = new MovingPoint(199, 199);
        p1.moveTo(202, 202);
        var b4: Box = new Box(220, 220, 2, 2);
        var c1: Circle = new Circle(221, 221, 4);

        load([b1, p1, b4], [b2, b3, c1]);

        execute();

        Assert.equals(1, b1.collisionsDetected);
        Assert.equals(2, b2.collisionsDetected);
        Assert.equals(2, b3.collisionsDetected);
        Assert.equals(2, b4.collisionsDetected);
        Assert.equals(2, p1.collisionsDetected);
        Assert.equals(1, c1.collisionsDetected);
    }
    

    function testCollisionsWithGjk()
    {
        var b1: Box = new Box(100, 100, 2, 2);
        var b2: Box = new Box(100, 100, 2, 2);
        b2.collisionsEnabled = false;
        var t1: Triangle = new Triangle([90, 90], [110, 110], [90, 80]); // yes
        var t2: Triangle = new Triangle([60, 60], [80, 80], [60, 80]); // no
        var c1: Circle = new Circle(90, 90, 20); // yes
        var c2: Circle = new Circle(90, 90, 2); // no
        var c3: Circle = new Circle(101, 101, 1); // yes

        load([b1, b2], [t1, t2, c1, c2, c3]);

        execute();

        Assert.equals(1, t1.collisionsDetected);
        Assert.equals(0, t2.collisionsDetected);
        Assert.equals(1, c1.collisionsDetected);
        Assert.equals(0, c2.collisionsDetected);
        Assert.equals(1, c3.collisionsDetected);
        Assert.equals(3, b1.collisionsDetected);
        Assert.equals(0, b2.collisionsDetected);
    }


    function debugPrintTree()
    {
        var buf: StringBuf = new StringBuf();
        visualize(buf);
        trace(buf.toString());
    }


    inline function type(d: Dynamic): String
    {
        return Type.getClassName(Type.getClass(d));
    }


    inline static function reverse<T>(arr: Array<T>): Array<T>
    {
        arr.reverse();
        return arr;
    }
}

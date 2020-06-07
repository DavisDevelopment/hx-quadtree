package tests;

import tests.models.Point;
import utest.Assert;
import tests.models.MovingBox;
import utest.ITest;

using quadtree.extensions.MovingRectangleEx;


class TestMovingRectangleEx implements ITest
{
    public function new() { }


    function testHull()
    {
        var movingBox: MovingBox = new MovingBox(0, 10, 100, 100);
        movingBox.moveTo(10, 30);

        Assert.equals(0, movingBox.hullX());
        Assert.equals(10, movingBox.hullY());
        Assert.equals(110, movingBox.hullWidth());
        Assert.equals(120, movingBox.hullHeight());
    }


    function testIntersectsPoint()
    {
        var b: MovingBox = new MovingBox(0, 0, 100, 100, 45);
        var p: Point = new Point(50, -3);

        Assert.isTrue( MovingRectangleEx.intersectsWithPoint(b.hullX(), b.hullY(), b.hullWidth(), b.hullHeight(), b.angle, p.x, p.y) );
    }
}

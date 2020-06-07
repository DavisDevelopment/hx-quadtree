package tests;

import tests.models.*;
import quadtree.helpers.BoundingBox;
import quadtree.gjk.Vector.AXIS_X;
import quadtree.gjk.Vector.AXIS_Y;
import utest.Assert;
import utest.ITest;

using quadtree.extensions.ColliderEx;


class TestColliderEx implements ITest
{
    public function new() { }


    function testGetBoundingBox()
    {
        /**
            Circle
        **/
        var circle: Circle = new Circle(0, 0, 50);
        var circleBounds: BoundingBox = new BoundingBox(0, 0);
        var circleBoundsExist: Bool = circle.getBoundingBox(circleBounds);
        Assert.isTrue(circleBoundsExist);
        Assert.equals(-50, circleBounds.x);
        Assert.equals(-50, circleBounds.y);
        Assert.equals(100, circleBounds.width);
        Assert.equals(100, circleBounds.height);


        /**
            Polygon
        **/
        var poly: EmptyPolygon = new EmptyPolygon();
        poly.points.push([ 0, 0 ]);
        poly.points.push([ 10, 0 ]);
        poly.points.push([ 0, 10 ]);
        var polyBounds: BoundingBox = new BoundingBox(0, 0);
        var polyBoundsExist: Bool = poly.getBoundingBox(polyBounds);
        Assert.isTrue(polyBoundsExist);
        Assert.equals(0, polyBounds.x);
        Assert.equals(0, polyBounds.y);
        Assert.equals(10, polyBounds.width);
        Assert.equals(10, polyBounds.height);


        /**
            Point
        **/
        var point: Point = new Point(12, 14);
        var pointBoundsExist: Bool = point.getBoundingBox(new BoundingBox(0, 0));
        Assert.isFalse(pointBoundsExist);
    }


    function testGetObjectDelta()
    {
        var movingPoint: MovingPoint = new MovingPoint(5, 10);
        movingPoint.moveTo(20, -5);
        Assert.equals(15, movingPoint.getObjectDelta(AXIS_X));
        Assert.equals(-15, movingPoint.getObjectDelta(AXIS_Y));

        var movingCircle: MovingCircle = new MovingCircle(5, 10, 20);
        movingCircle.moveTo(20, -5);
        Assert.equals(15, movingCircle.getObjectDelta(AXIS_X));
        Assert.equals(-15, movingCircle.getObjectDelta(AXIS_Y));
    }
}

package tests;

import tests.models.Circle;
import tests.models.MovingBox;
import tests.models.Box;
import utest.Assert;
import quadtree.helpers.MathUtils;
import quadtree.Physics;
import quadtree.gjk.Vector;
import quadtree.gjk.Vector.AXIS_X;
import quadtree.gjk.Vector.AXIS_Y;
import utest.ITest;

using quadtree.helpers.MathUtils;


@:access(quadtree.Physics)
class TestPhysics implements ITest
{
    public function new() { }


    function testMomentumConservationCollision()
    {
        var v1 = v(1, 0);
        var v2 = v(-1, 0);

        Physics.momentumConservationCollision(v1, v2, 0);

        Assert.isTrue( v1.equals(v(-1, 0)) );
        Assert.isTrue( v2.equals(v(1, 0)) );
    }


    function testComputeOverlapRect()
    {
        var b1 = new MovingBox(-25, -25, 50, 50);
        b1.moveTo(0, 0);

        var b2 = new MovingBox(25, 25, 50, 50);

        Assert.equals(25, Physics.computeOverlap(b1, b2, AXIS_X));
        Assert.equals(25, Physics.computeOverlap(b1, b2, AXIS_Y));

        Assert.equals(-25, Physics.computeOverlap(b2, b1, AXIS_X));
        Assert.equals(-25, Physics.computeOverlap(b2, b1, AXIS_Y));
    }


    function testComputeOverlapCircles()
    {
        var c1 = new Circle(0, 0, 100);
        var c2 = new Circle(100, 0, 50);
        var c3 = new Circle(200, 200, 10);

        Assert.equals(50, Physics.computeOverlap(c1, c2, AXIS_X));
        Assert.isTrue( Physics.computeOverlap(c1, c2, AXIS_Y).isZero() );

        Assert.equals(-50, Physics.computeOverlap(c2, c1, AXIS_X));
        Assert.isTrue( Physics.computeOverlap(c2, c1, AXIS_Y).isZero() );

        Assert.equals(0, Physics.computeOverlap(c1, c3, AXIS_X));
        Assert.equals(0, Physics.computeOverlap(c1, c3, AXIS_Y));
    }


    function testComputeOverlapCircleInRect()
    {
        var b = new MovingBox(-25, 0, 100, 100);
        b.moveTo(0, 0);
        var c = new Circle(100, 50, 10);

        Assert.equals(-10, Physics.computeOverlap(c, b, AXIS_X));
        Assert.isTrue( Physics.computeOverlap(c, b, AXIS_Y).isZero() );

        Assert.equals(10, Physics.computeOverlap(b, c, AXIS_X));
        Assert.isTrue( Physics.computeOverlap(b, c, AXIS_Y).isZero() );
    }


    function testSeparate()
    {
        var b1 = new MovingBox(-50, -50, 50, 50);
        b1.moveTo(0, 0);

        var b2 = new MovingBox(25, 25, 50, 50);
        
        var angle: Float = Physics.separate(b1, b2, false, true);

        Assert.isTrue( MathUtils.floatEquals(angle, Math.PI / 4) );

        Assert.equals(25, b2.x);
        Assert.equals(25, b2.y);
        
        Assert.equals(-25, b1.x);
        Assert.equals(-25, b1.y);
    }

    
    inline function v(x: Float, y: Float): Vector return new Vector(x, y);
}

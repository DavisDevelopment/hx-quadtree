package tests;

import quadtree.helpers.CollisionResult;
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
        var collisionResult: CollisionResult = new CollisionResult(new MovingBox(0, 0), new MovingBox(0, 0));
        collisionResult.obj1Velocity.set(1, 0);
        collisionResult.obj2Velocity.set(-1, 0);

        Physics.momentumConservationCollision(collisionResult);

        Assert.isTrue( collisionResult.obj1Velocity.equals(v(-1, 0)) );
        Assert.isTrue( collisionResult.obj2Velocity.equals(v(1, 0)) );
    }


    function testBounceCollision()
    {
        var box = new MovingBox(0, 0, 10, 10);
        var wall = new Box(20, -10, 10, 100);

        box.moveTo(12, 2);

        var collisionResult:CollisionResult = new CollisionResult(box, wall);

        Physics.separate(collisionResult);

        // Separation should have happened only on the x-axis.
        Assert.isTrue(collisionResult.separationHappened);
        Assert.floatEquals(0, collisionResult.separationAngle);
        Assert.floatEquals(0, collisionResult.overlapY);
        Assert.floatEquals(2, collisionResult.overlapX);
        Assert.floatEquals(10, box.x);
        Assert.floatEquals(2, box.y);
        Assert.floatEquals(20, wall.x);
        Assert.floatEquals(-10, wall.y);

        collisionResult.obj1Velocity.set(12, 2);
        collisionResult.obj1Elasticity = 0.5;

        Physics.momentumConservationCollision(collisionResult);

        vectorEquals([-6, 2], collisionResult.obj1Velocity);
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

        var collisionResult: CollisionResult = new CollisionResult(b1, b2);
        collisionResult.obj1Immovable = false;
        collisionResult.obj2Immovable = true;
        
        Physics.separate(collisionResult);

        Assert.equals(true, collisionResult.separationHappened);
        Assert.floatEquals(Math.PI / 4, collisionResult.separationAngle);

        Assert.equals(25, b2.x);
        Assert.equals(25, b2.y);
        
        Assert.equals(-25, b1.x);
        Assert.equals(-25, b1.y);
    }


    inline function vectorEquals(expected: Array<Float>, v: Vector)
    {
        Assert.equals(2, expected.length);
        Assert.floatEquals(expected[0], v.x);
        Assert.floatEquals(expected[1], v.y);
    }

    
    inline function v(x: Float, y: Float): Vector return new Vector(x, y);
}

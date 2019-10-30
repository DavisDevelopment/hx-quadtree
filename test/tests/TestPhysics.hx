package tests;

import utest.Assert;
import quadtree.helpers.MathUtils;
import quadtree.Physics;
import quadtree.gjk.Vector;
import utest.ITest;


class TestPhysics implements ITest
{
    public function new() { }


    function testMomentumConservationCollision()
    {
        var v1 = v(1, 0);
        var v2 = v(-1, 0);

        Physics.momentumConservationCollision(v1, v2, 1, 1);

        Assert.isTrue( v1.equals(v(-1, -1)) );
        Assert.isTrue( v2.equals(v(1, 1)) );
    }

    
    inline function v(x: Float, y: Float): Vector return new Vector(x, y);
}

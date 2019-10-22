package tests;

import utest.Assert;
import quadtree.gjk.Vector;
import utest.ITest;


class TestVector implements ITest
{
    public function new() { }


    function testEquals()
    {
        var v1: Vector = v(1, 2);
        var v2: Vector = v(1, 2);

        Assert.isTrue(v1.equals(v2));
    }


    function testCalcs()
    {
        var testCases = [
            {
                v1: v(1, 2),
                v2: v(-1, -2),
                expectedAdd: v(0, 0),
                expectedSub: v(2, 4),
                expectedDot: -5,
                expectedInvert: v(-1, -2),
                expectedPerp: v(2, -1)
            }
        ];

        doTestCases(testCases);
    }


    function doTestCases(testCases: Array<Dynamic>)
    {
        for (testCase in testCases)
        {
            var v1: Vector = cast testCase.v1;
            var v2: Vector = cast testCase.v2;
            
            Assert.isTrue(v1.copy().add(v2).equals(testCase.expectedAdd));
            Assert.isTrue(v1.copy().sub(v2).equals(testCase.expectedSub));
            Assert.equals(testCase.expectedDot, v1.copy().dotVector(v2));
            Assert.isTrue(v1.copy().invert().equals(testCase.expectedInvert));
            Assert.isTrue(v1.copy().perpendicular().equals(testCase.expectedPerp));
        }
    }


    inline function v(x: Float, y: Float): Vector return new Vector(x, y);
}

package tests;

import utest.Assert;
import quadtree.helpers.MathUtils;
import utest.ITest;


class TestMathUtils implements ITest
{
    static inline var AcceptableError = 0.05;
    static inline var Step = 0.1;

    public function new() { }


    function testSinCos()
    {
        var v: Float = -(2 * Math.PI);

        while (v < 2 * Math.PI)
        {
            var cos: Float = MathUtils.fastCos(v);
            var sin: Float = MathUtils.fastSin(v);

            var cosError: Float = Math.abs( Math.cos(v) - cos );
            var sinError: Float = Math.abs( Math.sin(v) - sin );

            Assert.isTrue(cosError < AcceptableError, 'v: $v, cos: $cos, realCos: ${Math.cos(v)}, cosError: $cosError');
            Assert.isTrue(sinError < AcceptableError, 'v: $v, sin: $sin, realSin: ${Math.sin(v)}, sinError: $sinError');

            v += Step;
        }
    }


    function testAbsMinMax()
    {
        Assert.equals(5, MathUtils.maxAbs(5, 4));
        Assert.equals(-5, MathUtils.maxAbs(-5, 4));
        Assert.equals(5, MathUtils.minAbs(5, -10));
        Assert.equals(-5, MathUtils.minAbs(-5, 10));
        Assert.equals(5, MathUtils.minAbs(5, 10));
        Assert.equals(-10, MathUtils.maxAbs(5, -10));
        Assert.equals(-5, MathUtils.minAbs(10, -5));
    }
}

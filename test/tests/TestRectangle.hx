package tests;

import utest.Assert;
import utest.ITest;
import quadtree.Rectangle;
import tests.models.Box;

using quadtree.RectangleUtils;


class TestRectangle implements ITest
{
    public function new()
    {

    }


    function testContains()
    {
        var rect: Rectangle = new Box(100, 100, 200, 200);

        var testCases = [
            {
                other: new Box(150, 150),
                expected: true
            }
        ];

        doBoolTestCases(rect.contains, testCases);
    }


    function doBoolTestCases(method: (Rectangle) -> Bool, testCases: Array<Dynamic>)
    {
        for (testCase in testCases)
        {
            var other: Rectangle            = cast testCase.other;
            var expected: Bool              = cast testCase.expected;

            Assert.equals(expected, method(other));
        }
    }
}


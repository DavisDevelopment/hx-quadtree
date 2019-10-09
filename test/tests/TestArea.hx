package tests;

import utest.Assert;
import utest.ITest;
import quadtree.Area;
import quadtree.areas.BoundingBox;
import quadtree.areas.Rectangle;

using quadtree.AreaUtils;


class TestArea implements ITest
{
    public function new()
    {

    }


    function testContains()
    {
        var rect: Rectangle = new BoundingBox(100, 100, 200, 200);

        var testCases = [
            {
                other: new BoundingBox(150, 150),
                expected: true
            },
            {
                other: new BoundingBox(150, 150, 200, 200),
                expected: false
            },
            {
                other: new BoundingBox(150, 150, 50, 50),
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


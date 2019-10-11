package tests;

import tests.models.Point;
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


    function testContainsArea()
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

        doAreaBoolTestCases(rect.containsAreaInArea, testCases);
    }


    function testContainsPoint()
    {
        var rect: Rectangle = new BoundingBox(100, 100, 200, 200);

        var testCases = [
            {
                other: new Point(150, 150),
                expected: true
            },
            {
                other: new Point(50, 50),
                expected: false
            },
            {
                other: new Point(555, 555),
                expected: false
            }
        ];

        doPointBoolTestCases(rect.containsPointInArea, testCases);
    }


    function doAreaBoolTestCases(method: Area -> Bool, testCases: Array<Dynamic>)
    {
        for (testCase in testCases)
        {
            var other: Area             = cast testCase.other;
            var expected: Bool          = cast testCase.expected;

            Assert.equals(expected, method(other));
        }
    }


    function doPointBoolTestCases(method: Point -> Bool, testCases: Array<Dynamic>)
    {
        for (testCase in testCases)
        {
            var other: Point            = cast testCase.other;
            var expected: Bool          = cast testCase.expected;

            Assert.equals(expected, method(other));
        }
    }
}


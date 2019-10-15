package tests;

import quadtree.QuadTree;
import tests.models.Point;
import tests.models.BoundingBox;
import utest.Assert;
import utest.ITest;
import quadtree.Area;
import quadtree.areas.Rectangle;

using quadtree.QuadTreeEx;


class TestQuadTreeEx implements ITest
{
    public function new()
    {

    }


    function testContainsArea()
    {
        var qt: QuadTree = new QuadTree(100, 100, 200, 200);

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

        doAreaBoolTestCases(qt.containsArea, testCases);
    }


    function testIsContainedInArea()
    {
        var qt: QuadTree = new QuadTree(100, 100, 200, 200);

        var testCases = [
            {
                other: new BoundingBox(150, 150),
                expected: false
            },
            {
                other: new BoundingBox(150, 150, 200, 200),
                expected: false
            },
            {
                other: new BoundingBox(150, 150, 50, 50),
                expected: false
            },
            {
                other: new BoundingBox(50, 50, 150, 150),
                expected: false
            },
            {
                other: new BoundingBox(50, 50, 300, 300),
                expected: true
            },
            {
                other: new BoundingBox(100, 100, 200, 200),
                expected: true
            },
            {
                other: new BoundingBox(1, 1, 199, 199),
                expected: false
            }
        ];

        doAreaBoolTestCases(qt.isContainedInArea, testCases);
    }


    function testContainsPoint()
    {
        var qt: QuadTree = new QuadTree(100, 100, 200, 200);

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

        doPointBoolTestCases(qt.containsPoint, testCases);
    }


    function doAreaBoolTestCases(method: (Int, Int, Int, Int) -> Bool, testCases: Array<Dynamic>)
    {
        for (testCase in testCases)
        {
            var other: Area             = cast testCase.other;
            var expected: Bool          = cast testCase.expected;
            
            var objLeftEdge: Int = other.x;
            var objTopEdge: Int = other.y;
            var objRightEdge: Int = other.x + other.width;
            var objBottomEdge: Int = other.y + other.height;

            Assert.equals(expected, method(objLeftEdge, objTopEdge, objRightEdge, objBottomEdge));
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


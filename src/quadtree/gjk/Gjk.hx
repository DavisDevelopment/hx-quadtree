package quadtree.gjk;

import quadtree.Constants.Floats;
import quadtree.types.Polygon;


/**
    Implementation of the Gilbert-Johnson-Keerthi 2D collision detection algorithm.
    As studied at: https://jamiethompson.me/posts/GJK-Collision-Detection/
**/
class Gjk
{
    var vectorPool: VectorLinkedList;


    public function new() { }


    function getSupportVector(a: Polygon, b: Polygon, direction: Vector): Vector
    {
        var aFarthest: Vector = getFarthestPointInDirection(a, direction);
        var bFarthest: Vector = getFarthestPointInDirection(a, direction.invert());
        aFarthest.sub(bFarthest);
        destroyVector(bFarthest);
        return aFarthest;
    }


    function getFarthestPointInDirection(p: Polygon, direction: Vector): Vector
    {
        var biggestDistance: Float = Floats.MIN;
        var farthestPoint: Vector = recycleVector();

        for (point in p.points)
        {
            var distanceInDirection: Float = direction.dot(point[0], point[1]);

            if (distanceInDirection > biggestDistance)
            {
                farthestPoint.set(point[0], point[1]);
                biggestDistance = distanceInDirection;
            }
        }

        return farthestPoint;
    }


    @:allow(quadtree.gjk.Simplex)
    inline function recycleVector(x: Float = 0, y: Float = 0): Vector
    {
        var v: Vector;
        if (vectorPool == null)
        {
            v = new VectorLinkedList(x, y);
        }
        else
        {
            v = vectorPool;
            v.set(x, y);
            vectorPool = vectorPool.next;
        }
        return v;
    }

    
    @:allow(quadtree.gjk.Simplex)
    inline function copyVector(v: Vector): Vector
    {
        return recycleVector(v.x, v.y);
    }


    @:allow(quadtree.gjk.Simplex)
    inline function destroyVector(v: Vector)
    {
        cast(v, VectorLinkedList).next = vectorPool;
        vectorPool = cast(v, VectorLinkedList);
    }
}

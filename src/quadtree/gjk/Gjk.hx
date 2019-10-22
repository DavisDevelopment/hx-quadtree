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


    public function checkOverlap(a: Polygon, b: Polygon): Bool
    {
        // Build a new Simplex for determining if a collision has occurred.
        var simplex: Simplex = new Simplex();

        // Choose an arbitrary starting direction.
        var direction: Vector = recycleVector(0, 1);

        // Get the first support point and add it to the simplex.
        var supportPoint: Vector = getSupportVector(a, b, direction);
        simplex.push(supportPoint);

        // Flip the direction for the next support point.
        direction.invert();

        var COUNT = 0;

        while (direction != null)
        {
            supportPoint = getSupportVector(a, b, direction);

            // If the support point did not reach as far as the origin,
            // the simplex must not contain the origin and therefore there is no
            // intersection.
            if (supportPoint.dotVector(direction) <= 0) 
            {
                // No intersection
                destroyVector(supportPoint);
                destroyVector(direction);
                simplex.destroy(this);
                return false;
            }

            destroyVector(direction);

            // Add the simplex and determine a new direction.
            simplex.push(supportPoint);
            direction = simplex.calculateDirection(this);

            //if (COUNT++ > 100) break;
        }

        simplex.destroy(this);

        return true;
    }


    function getSupportVector(a: Polygon, b: Polygon, direction: Vector): Vector
    {
        var aFarthest: Vector = getFarthestPointInDirection(a, direction);
        var bFarthest: Vector = getFarthestPointInDirection(b, direction.invert());
        direction.invert();
        destroyVector(bFarthest);
        return aFarthest.sub(bFarthest);
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

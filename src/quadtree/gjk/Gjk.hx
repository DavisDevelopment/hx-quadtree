package quadtree.gjk;

import quadtree.Constants.Floats;
import quadtree.types.Polygon;


/**
    Implementation of the Gilbert-Johnson-Keerthi 2D collision detection algorithm.
    As studied at: https://jamiethompson.me/posts/GJK-Collision-Detection/
**/
class Gjk
{
    /** Cache for reusing Vector objects. **/
    var vectorPool: VectorLinkedList;


    public function new() { }


    /**
        Checks whether two given polygons overlap.

        @return Returns `true` if they overlap and `false` if they don't.
    **/
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
        }

        simplex.destroy(this);

        return true;
    }


    function getSupportVector(a: Polygon, b: Polygon, direction: Vector): Vector
    {
        var aFarthest: Vector = getFarthestPointInDirection(a, direction);
        var bFarthest: Vector = getFarthestPointInDirection(b, direction.invert());
        /*
        trace('a: ${polygonToString(a)}');
        trace('b: ${polygonToString(b)}');
        trace('dir: ${direction.toString()}');
        trace('aFarthest: ${aFarthest.toString()}');
        trace('bFarthest: ${bFarthest.toString()}');
        trace('support: ${aFarthest.copy().sub(bFarthest).toString()}\n');
        */
        
        direction.invert();
        destroyVector(bFarthest);
        return aFarthest.sub(bFarthest);
    }


    function getFarthestPointInDirection(p: Polygon, direction: Vector): Vector
    {
        var biggestDistance: Float = 0;
        var farthestPoint: Vector = null;

        for (point in p.points)
        {
            var distanceInDirection: Float = direction.dot(point[0], point[1]);

            if (distanceInDirection > biggestDistance || farthestPoint == null)
            {
                if (farthestPoint == null)
                {
                    farthestPoint = recycleVector(point[0], point[1]);
                }
                else
                {
                    farthestPoint.set(point[0], point[1]);
                }
                biggestDistance = distanceInDirection;
            }
        }

        return farthestPoint;
    }


    @:allow(quadtree.gjk.Simplex)
    inline function recycleVector(x: Float = 0, y: Float = 0): Vector
    {
        var v: Vector;
        if (vectorPool == null || true)
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


    function polygonToString(poly: Polygon): String
    {
        var buf: StringBuf = new StringBuf();
        buf.add("[");
        for (p in poly.points)
        {
            buf.add(' (${p[0]}, ${p[1]})');
        }
        buf.add(" ]");
        return buf.toString();
    }
}

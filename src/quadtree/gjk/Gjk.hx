package quadtree.gjk;

import quadtree.types.Point;
import quadtree.types.Rectangle;
import quadtree.types.MovingPoint;
import quadtree.types.MovingRectangle;
import quadtree.types.Circle;
import quadtree.types.Collider;
import quadtree.types.Polygon;

using quadtree.extensions.PointEx;
using quadtree.extensions.CircleEx;
using quadtree.extensions.PolygonEx;
using quadtree.extensions.RectangleEx;
using quadtree.extensions.MovingPointEx;
using quadtree.extensions.MovingRectangleEx;


/**
    Implementation of the Gilbert-Johnson-Keerthi 2D collision detection algorithm.
    As studied at: https://jamiethompson.me/posts/GJK-Collision-Detection/
**/
class Gjk
{
    /** Cache for reusing Vector objects. **/
    var vectorPool: VectorLinkedList;

    var simplex: Simplex;


    public function new()
    {
        simplex = new Simplex();
    }


    /**
        Checks whether two given colliders overlap.

        @return Returns `true` if they overlap and `false` if they don't.
    **/
    public function checkOverlap(a: Collider, b: Collider): Bool
    {
        // Build a new Simplex for determining if a collision has occurred.
        simplex.reset();

        // Choose an arbitrary starting direction.
        var direction: Vector = recycleVector(1, 0);

        // Get the first support point and add it to the simplex.
        var supportPoint: Vector = getSupportVector(a, b, direction);
        simplex.push(supportPoint);

        // Flip the direction for the next support point.
        direction.invert();

        while (direction != null)
        {
            direction.normalize();
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


    function getSupportVector(a: Collider, b: Collider, direction: Vector): Vector
    {
        var aFarthest: Vector = getFarthestPointInDirection(a, direction);
        var bFarthest: Vector = getFarthestPointInDirection(b, direction.invert());
        direction.invert();
        destroyVector(bFarthest);
        return aFarthest.sub(bFarthest);
    }


    function getFarthestPointInDirection(c: Collider, direction: Vector): Vector
    {
        return switch c.areaType
        {
            case Polygon | MovingPolygon: cast(c, Polygon).getFarthestPointInDirection(direction, recycleVector());

            case Circle | MovingCircle: cast(c, Circle).getFarthestPointInDirection(direction, recycleVector());

            case Point: cast(c, Point).getFarthestPointInDirection(direction, recycleVector());

            case MovingPoint: cast(c, MovingPoint).getFarthestPointInDirection(direction, recycleVector());

            case Rectangle: cast(c, Rectangle).getFarthestPointInDirection(direction, recycleVector());

            case MovingRectangle: cast(c, MovingRectangle).getFarthestPointInDirection(direction, recycleVector());

            case _: throw "Not implemented";
        }
    }


    @:allow(quadtree.gjk.Simplex)
    inline function recycleVector(x: Float = 0, y: Float = 0): Vector
    {
        var v: VectorLinkedList;
        if (vectorPool == null)
        {
            v = new VectorLinkedList(x, y);
        }
        else
        {
            v = vectorPool;
            vectorPool = vectorPool.next;

            v.set(x, y);
            v.next = null;
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


    @IgnoreCover
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

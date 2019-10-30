package quadtree.helpers;

import quadtree.types.Rectangle;
import quadtree.types.Circle;
import quadtree.gjk.Vector.AXIS_X;
import quadtree.gjk.Vector.AXIS_Y;

using quadtree.helpers.MathUtils;
using quadtree.extensions.CircleEx;


class Overlap
{
    public static function circleInCircle(c1: Circle, c2: Circle, axis: Int): Float
    {
        var centersDistance: Float = c1.centerDistanceTo(c2.centerX, c2.centerY);
        var radialOverlap: Float = c1.radius + c2.radius - centersDistance;

        if (radialOverlap <= 0)
        {
            return 0;
        }

        var angle: Float = MathUtils.angleBetween(c1.centerX, c1.centerY, c2.centerX, c2.centerY);

        if (axis == AXIS_X)
        {
            return radialOverlap * MathUtils.fastCos(angle);
        }
        else
        {
            return radialOverlap * MathUtils.fastSin(angle);
        }
    }


    public static function alignedRectangleInAlignedRectangle(r1: Rectangle, r2: Rectangle, axis: Int, delta: Float): Float
    {
        return switch axis
        {
            // |-x----- r1 -> r2 ---------
            case AXIS_X if (delta > 0): r1.x + r1.width - r2.x;

            // |-x----- r2 <- r1 ---------
            case AXIS_X if (delta < 0): r1.x - r2.x - r2.width;
            /*
            case AXIS_X if (Math.abs(r1.x + r1.width - r2.x) < Math.abs(r1.x - r2.x - r2.width)): r1.x + r1.width - r2.x;

            case AXIS_X: r1.x - r2.x - r2.width;
            */

            // |-y----- r1 -> r2 ---------
            case AXIS_Y if (delta > 0): r1.y + r1.height - r2.y;

            // |-y----- r2 <- r1 ---------
            case AXIS_Y if (delta < 0): r1.y - r2.y - r2.height;

            /*
            case AXIS_Y if (Math.abs(r1.y + r1.height - r2.y) < Math.abs(r1.y - r2.y - r2.height)): r1.y + r1.height - r2.y;

            case AXIS_Y: r1.y - r2.y - r2.height;
            */

            case _: 0;
        }
    }


    public static function circleInAlignedRectangle(c: Circle, r: Rectangle, axis: Int, delta: Float): Float
    {
        return switch axis
        {
            // |-x----- c -> r ---------
            case AXIS_X if (delta > 0): c.centerX + c.radius - r.x;

            // |-x----- r <- c ---------
            case AXIS_X if (delta < 0): c.centerX - c.radius - r.x - r.width;

            /*
            case AXIS_X if (Math.abs(c.centerX + c.radius - r.x) < Math.abs(c.centerX - c.radius - r.x - r.width)): c.centerX + c.radius - r.x;

            case AXIS_X: c.centerX - c.radius - r.x - r.width;
            */

            // |-y----- c -> r ---------
            case AXIS_Y if (delta > 0): c.centerY + c.radius - r.y;

            // |-y----- r <- c ---------
            case AXIS_Y if (delta < 0): c.centerY - c.radius - r.y - r.height;

            /*
            case AXIS_Y if (Math.abs(c.centerY + c.radius - r.y) < Math.abs(c.centerY - c.radius - r.y - r.height)): c.centerY + c.radius - r.y;

            case AXIS_Y: c.centerY - c.radius - r.y - r.height;
            */

            case _: 0;
        }
    }
}

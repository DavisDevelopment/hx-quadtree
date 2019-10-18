package tests.models;

import quadtree.CollisionAreaType;
import quadtree.types.Rectangle;
import quadtree.Constants.Ints;


class Box implements Rectangle
{
    /** Returns a bounding box with its top left corner on (0, 0) and the maximum size. **/
    public static var Max(get, never): Box;

    public var areaType: CollisionAreaType = CollisionAreaType.Rectangle;
    
    public var x: Int;
    public var y: Int;
    public var width: Int;
    public var height: Int;

    public var collisionDetected: Bool = false;


    public function new(x: Int, y: Int, width: Int = 0, height: Int = 0)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }


    public function onOverlap(other: quadtree.types.Point): Void
    {
        collisionDetected = true;
    }


    static function get_Max(): Box
    {
        return new Box(0, 0, Ints.MAX, Ints.MAX);
    }
}


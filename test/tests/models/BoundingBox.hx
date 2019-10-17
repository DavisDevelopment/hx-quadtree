package tests.models;

import quadtree.types.Point.CollisionAreaType;
import quadtree.types.Rectangle;
import quadtree.Constants.Ints;


class BoundingBox implements Rectangle
{
    /** Returns a bounding box with its top left corner on (0, 0) and the maximum size. **/
    public static var Max(get, never): BoundingBox;

    public var areaType: CollisionAreaType = CollisionAreaType.Rectangle;
    
    public var x: Int;
    public var y: Int;
    public var width: Int;
    public var height: Int;


    public function new(x: Int, y: Int, width: Int = 0, height: Int = 0)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }


    static function get_Max(): BoundingBox
    {
        return new BoundingBox(0, 0, Ints.MAX, Ints.MAX);
    }
}


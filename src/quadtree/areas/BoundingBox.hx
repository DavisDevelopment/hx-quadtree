package quadtree.areas;

import quadtree.areas.Rectangle;
import quadtree.Area;
import quadtree.Constants.Ints;


class BoundingBox implements Rectangle
{
    /** Returns a bounding box with its top left corner on (0, 0) and the maximum size. **/
    public static var Max(get, never): BoundingBox;

    public var areaType(default, never): AreaType;
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


    @IgnoreCover
    static function get_Max(): BoundingBox
    {
        return new BoundingBox(0, 0, Ints.MAX, Ints.MAX);
    }
    

    @IgnoreCover
    static function get_areaType(): AreaType return AreaType.Rectangle;
}

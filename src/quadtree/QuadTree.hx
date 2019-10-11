package quadtree;

import quadtree.Point;
import quadtree.areas.BoundingBox;

using quadtree.AreaUtils;


class QuadTree<T: Point>
{
    var objects0: Array<T>;
    var objects1: Array<T>;

    var boundaries: BoundingBox;

    var depth: Int;


    public function new(?boundaries: BoundingBox)
    {
        reset(boundaries);
    }


    function reset(?boundaries: BoundingBox)
    {
        this.boundaries = boundaries != null ? boundaries : BoundingBox.Max;

        objects0 = new Array<T>();
        objects1 = new Array<T>();
        depth = 0;
    }


    public function add(object: T, list: Int = 0)
    {
    }
}

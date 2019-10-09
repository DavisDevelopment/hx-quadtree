package quadtree;

import quadtree.areas.BoundingBox;


class QuadTree<T: Area>
{
    var objects: Array<T>;
    var boundaries: BoundingBox;

    var depth: Int;


    public function new(boundaries: BoundingBox)
    {
        this.boundaries = boundaries;

        objects = new Array<T>();
        depth = 0;
    }
}

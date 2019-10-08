package tests.models;

import quadtree.Rectangle;


class Box implements Rectangle
{
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
}

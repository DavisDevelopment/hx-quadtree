package tests.models;


class Point implements quadtree.Point
{
    public var x: Int;
    public var y: Int;


    public function new(x: Int, y: Int) 
    {
        this.x = x;
        this.y = y;        
    }
}

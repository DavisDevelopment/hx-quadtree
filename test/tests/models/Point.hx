package tests.models;

import quadtree.CollisionAreaType;


class Point implements quadtree.types.Point
{
    public var areaType: CollisionAreaType = CollisionAreaType.Point;
    
    public var x: Int;
    public var y: Int;


    public function new(x: Int, y: Int) 
    {
        this.x = x;
        this.y = y;        
    }
}

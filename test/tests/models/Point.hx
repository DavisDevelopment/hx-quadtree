package tests.models;

import quadtree.CollisionAreaType;


class Point implements quadtree.types.Point
{
    public var areaType: CollisionAreaType = CollisionAreaType.Point;
    
    public var x: Float;
    public var y: Float;

    public var collisionsDetected: Float = 0;


    public function new(x: Float, y: Float) 
    {
        this.x = x;
        this.y = y;
    }


    public function onOverlap(other: quadtree.types.Point): Void
    {
        collisionsDetected++;
    }
}

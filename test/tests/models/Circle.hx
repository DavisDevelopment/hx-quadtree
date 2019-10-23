package tests.models;

import quadtree.types.Collider;
import quadtree.CollisionAreaType;
import quadtree.types.Rectangle;
import quadtree.Constants.Ints;


class Circle implements quadtree.types.Circle
{
    public var areaType: CollisionAreaType = CollisionAreaType.Circle;
    public var collisionsEnabled: Bool = true;

    public var collisionsDetected: Float = 0;

    public var centerX: Float;
    public var centerY: Float;
    public var radius: Float;


    public function new(x: Float, y: Float, radius: Float)
    {
        centerX = x;
        centerY = y;
        this.radius = radius;
    }


    public function onOverlap(other: Collider): Void
    {
        collisionsDetected++;
    }
}


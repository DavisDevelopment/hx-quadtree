package tests.models;

import quadtree.helpers.MathUtils;
import quadtree.CollisionAreaType;
import quadtree.types.MovingRectangle;


class MovingCircle extends Circle implements quadtree.types.MovingCircle
{
    public var lastX: Float;
    public var lastY: Float;


    public function new(x: Float, y: Float, radius: Float)
    {
        super(x, y, radius);

        lastX = centerX;
        lastY = centerY;

        areaType = CollisionAreaType.MovingCircle;
    }


    public function moveTo(x: Float, y: Float)
    {
        lastX = centerX;
        lastY = centerY;

        centerX = x;
        centerY = y;
    }
}

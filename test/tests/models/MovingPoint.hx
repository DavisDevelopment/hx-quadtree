package tests.models;

import quadtree.CollisionAreaType;
import quadtree.types.MovingRectangle;


class MovingPoint extends Point implements quadtree.types.MovingPoint
{
    public var lastX: Float;
    public var lastY: Float;


    public function new(x: Float, y: Float)
    {
        super(x, y);

        lastX = this.x;
        lastY = this.y;

        areaType = CollisionAreaType.MovingPoint;
    }


    public function moveTo(x: Float, y: Float)
    {
        lastX = this.x;
        lastY = this.y;

        this.x = x;
        this.y = y;
    }
}

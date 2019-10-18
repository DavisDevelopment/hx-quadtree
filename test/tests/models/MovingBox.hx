package tests.models;

import quadtree.types.MovingRectangle;


class MovingBox extends Box implements MovingRectangle
{
    public var lastX: Float;


    public var lastY: Float;
}

package quadtree.types;


interface Polygon extends Collider
{
    /**
        The x-coordinate of the polygon's reference point.
        All values in the `points` array are treated as relative to this point.
    **/
    public var refX(default, never): Float;


    /**
        The y-coordinate of the polygon's reference point.
        All values in the `points` array are treated as relative to this point.
    **/
    public var refY(default, never): Float;


    /**
        An **Nx2** array, where every row is a point of the polygon in the form of **[x, y]**.
    **/
    public var points(default, never): Array<Array<Float>>;
}

package quadtree.types;


interface Polygon extends Collider
{
    /**
        An **Nx2** array, where every row is a point of the polygon in the form of **[x, y]**.
    **/
    public var points(default, never): Array<Array<Float>>;
}

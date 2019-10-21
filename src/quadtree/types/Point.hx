package quadtree.types;


interface Point extends Collider
{
    /** The x-coordinate of the point. **/
    public var x(default, never): Float;
    

    /** The y-coordinate of the point. **/
    public var y(default, never): Float;
}

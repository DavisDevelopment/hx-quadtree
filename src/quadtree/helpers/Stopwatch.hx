package quadtree.helpers;



class Stopwatch
{
    static var timestamp: Float = 0;


    public static inline function start()
    {
        timestamp = getTimestamp();
    }


    public static inline function elapsed(): Float
    {
        return getTimestamp() - timestamp;
    }


    public static inline function printElapsedAndReset(msg: String = "")
    {
        Sys.println('Elapsed ($msg): ${elapsed()}');
        start();
    }


    /**
        Returns the current timestamp in seconds.
    **/
    static inline function getTimestamp(): Float
    {
        #if sys
            return Sys.time();
        #else
            return Date.now().getTime() / 1000;
        #end
    }
}

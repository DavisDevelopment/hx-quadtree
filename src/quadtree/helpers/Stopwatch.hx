package quadtree.helpers;


@IgnoreCover
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
        #if sys
        Sys.println('Elapsed ($msg): ${elapsed()}');
        #end
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

class Main
{
    static public var log = new debug.Logger("Special", WARN, ERROR); // logs warnings, throws exceptions on errors
    static public function main():Void
    {
        log("test log"); // Output: Special - test log
        log.warn("test log"); // Output: Special - WARN:test log
        log.info("test log"); // ignored
        log.setPriority(INFO);
        log.info("test log"); // Special - INFO:test log
        log.verbose("test log"); // ignored
        log.verbose.enabled = true;
        log.verbose("test log"); // Output: Special - VERBOSE:test log
        try
        {
            log.error("test log"); // throws exception
        }
        catch(e)
        {
            log('exception thrown: ${e.message}'); // Output: Special - exception thrown: Special - ERROR:test log
        }
        // set custom logger
        log.formatter = (priority, msg, ?pos) -> 'SPECIAL_$priority:$msg';
        log.error.throws = false;
        log.error("test log"); // Output: SPECIAL_ERROR:test log
    }
}
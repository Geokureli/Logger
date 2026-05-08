import debug.Logger.assert as gAssert;
import debug.Logger.log as gLog;

using debug.ansi.StyleTools;
class Main
{
    static public var log = new debug.Logger("Main", WARN, ERROR); // logs warnings, throws exceptions on errors
    static public var altLog = new debug.Logger("Alt", INFO, ERROR); // logs warnings, throws exceptions on errors
    static public function main():Void
    {
        log("--- Testing logs --- "); // Output: Main: test log
        log.warn("test log"); // Output: Main: WARN:test log
        log.info("test log"); // ignored
        log.setPriority(INFO);
        log.info("test log"); // Main: INFO:test log
        log.verbose("test log"); // ignored
        log.sub("Sub").verbose("test sub log"); // ignored
        log.sub('Sub[${"Context".style(WHITE)}]').verbose("test sub log");
        log.verbose.enabled = true;
        log.verbose("test log"); // Output: Main: VERBOSE:test log
        try
        {
            log.error("test log"); // throws exception
        }
        catch(e)
        {
            gLog('exception caught: ${e.message}'); // Output: exception caught: Main[ERROR]:test log
        }
        
        altLog("--- Testing Alt logs --- "); // Output: Alt: test log
        altLog.warn("test log"); // Output: Alt: WARN:test log
        altLog.info("test log"); // ignored
        altLog.setPriority(INFO);
        altLog.info("test log"); // Alt: INFO:test log
        altLog.verbose("test log"); // ignored
        altLog.sub("Sub").verbose("test sub log"); // ignored
        altLog.sub("Sub[Context]").verbose("test sub log"); // ignored
        altLog.verbose.enabled = true;
        altLog.verbose("test log"); // Output: Alt: VERBOSE:test log
        
        // subs
        log("--- Testing subs ---");
        final logSub = log.sub("Sub[TEST]");
        logSub.warn("test sub log");
        logSub.info("test sub log");
        logSub.verbose("test sub log");
        logSub.sub("Supersup".style(GREEN)).verbose("test " + "supersub".style(RED) + " log");
        
        final altLogSub = altLog.sub("Sub[TEST]");
        altLogSub.warn("test sub log");
        altLogSub.info("test sub log");
        altLogSub.verbose("test sub log");
        altLogSub.sub("supersup").verbose("test supersub log");
        
        // asserts
        log("--- Testing asserts ---");
        log.verbose.assert(5 < 3);
        log.info.assert(5 < 3);
        log.warn.assert(5 < 3);
        try
        {
            log.assert(5 < 3); // throws exception
        }
        catch(e)
        {
            gLog('Exception caught: ${e.message}'); // Output: Exception caught: Main[ERROR]: Assertion failed: 5 < 3
        }
        // set custom logger
        log.formatter = (priority, msg, ?pos) -> 'MAIN_$priority:$msg';
        log.error.throws = false;
        log.error("test log"); // Output: MAIN_ERROR:test log
        
        // Global logger (notice `import debug.Logger.log as gLog;`)
        gLog("test log");
        gLog.warn("test log");
        gLog.info("test log");
        gLog.verbose("test log");
        try
        {
            gAssert(5 < 3); // throws exception
        }
        catch(e)
        {
            gLog('Exception caught: ${e.message}'); // Output: Exception caught: ERROR: Assertion failed: 5 < 3
        }
    }
}
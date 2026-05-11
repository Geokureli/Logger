import debug.Logger.assert as gAssert;
import debug.Logger.log as gLog;

using debug.ansi.StyleTools;
class Main
{
    static public var log = new debug.Logger("Main", WARN, ERROR); // logs warnings, throws exceptions on errors
    static public var altLog = new debug.Logger("Alt", INFO, ERROR); // logs warnings, throws exceptions on errors
    static public function main():Void
    {
        // -D main.log=warn
        log("--- Testing logs --- "); // Output: --- Testing logs ---
        log.warn("test log");         // Output: Main: WARN:test log
        log.info("test log");         // Ignored via: -D main.log=warn
        log.setPriority(INFO);
        log.info("test log");         // Main: INFO:test log
        log.verbose("test log");      // Ignored
        log.verbose.enabled = true;
        log.verbose("test log");      // Output: Main: VERBOSE:test log
        try
        {
            log.error("test log");
        }
        catch(e)
        {
            gLog('exception caught: ${e.message}'); // Output: exception caught: Main[ERROR]:test log
        }
        
        // -D alt.log=info
        altLog("--- Testing Alt logs --- ");                // Output: Alt: --- Testing Alt logs --- 
        altLog.warn("test log");                            // Output: Alt: WARN:test log
        altLog.info("test log");                            // Output: Alt[INFO]: test log
        altLog.verbose("test log");                         // Ignored
        
        // -D main.sub.log=verbose
        log("--- Testing subs ---");                         // Output: Main: --- Testing subs ---
        final logSub = log.sub("Sub"+"[CONTEXT]".color(GREEN));
        logSub.warn("test sub log");                         // Output: Main.Sub[WARN]: test sub log
        logSub.info("test sub log");                         // Output: Main.Sub[INFO]: test sub log
        logSub.verbose("test sub log");                      // Output: Main.Sub[VERBOSE]: test sub log
        logSub.sub("Supersup").verbose("test supersub log"); // Output: Main.Sub.Supersup[VERBOSE]: test supersub log
        
        //-D alt.log=info
        final altLogSub = altLog.sub('Sub[TEST]');
        altLogSub.warn("test sub log");
        altLogSub.info("test sub log");
        altLogSub.verbose("test sub log");
        altLogSub.sub("Supersup").verbose("test supersub log");
        
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
        log.formatter = function (priority, msg, ?pos) 
        {
            final priStr = priority == NONE ? "" : '_$priority';
            return 'MAIN$priStr:$msg';
        }
        log.error.throws = false;
        log.error("test log"); // Output: MAIN_ERROR:test log
        
        // Global logger (notice `import debug.Logger.log as gLog;`)
        log("--- Testing global log ---");
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
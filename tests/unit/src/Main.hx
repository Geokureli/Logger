import debug.Logger;
import debug.LoggerPriority;
import debug.ansi.StyleTools;
import utest.Assert as UAssert;

class Main
{
    static public function main():Void
    {
        utest.UTest.run
        (   [ new Test1()
            ]
        );
        trace("done");
    }
}
class Test1 extends Test
{
    var log1:Logger;
    var log2:Logger;
    
    override function initLoggers()
    {
        super.initLoggers();
        
        log1 = new Logger("test1", WARN, ERROR);
        log2 = new Logger("test2", WARN, ERROR);
    }
    
    function testDefaults()
    {
        // test global logger
        UAssert.equals(true, Logger.log.verbose.enabled);
        UAssert.equals(false, Logger.log.verbose.throws);
        
        UAssert.equals(true, Logger.log.info.enabled);
        UAssert.equals(false, Logger.log.info.throws);
        
        UAssert.equals(true, Logger.log.warn.enabled);
        UAssert.equals(false, Logger.log.warn.throws);
        
        UAssert.equals(true, Logger.log.error.enabled);
        UAssert.equals(true, Logger.log.error.throws);
        
        // test category
        UAssert.equals(false, log1.verbose.enabled);
        UAssert.equals(false, log1.verbose.throws);
        
        UAssert.equals(false, log1.info.enabled);
        UAssert.equals(false, log1.info.throws);
        
        UAssert.equals(true, log1.warn.enabled);
        UAssert.equals(false, log1.warn.throws);
        
        UAssert.equals(true, log1.error.enabled);
        UAssert.equals(true, log1.error.throws);
    }
    
    function testPriorityFields()
    {
        function checkPriority(priority:LoggerPriority, id:String)
        {
            final testMsg = 'log succeeded';
            lastLog = null;
            
            priority.throws = false;
            priority.enabled = true;
            priority(testMsg);
            UAssert.notEquals(null, lastLog, 'Expected $id.${priority.level} to not log');
            
            lastLog = null;
            
            priority.enabled = false;
            priority(testMsg);
            UAssert.equals(null, lastLog, 'Expected $id.${priority.level} to log');
            
            priority.throws = false;
            priority.assert(false, testMsg);
            UAssert.equals(null, lastLog, 'Expected $id.${priority.level}.assert to not log');
            
            priority.throws = true;
            try
            {
                priority.assert(false, testMsg);
                UAssert.fail("Expected thrown exception");
            }
            catch(e)
            {
                UAssert.pass();
                UAssert.equals(null, lastLog, 'Expected $id.${priority.level}.assert to not log');
            }
        }
        
        checkPriority(log1.verbose, "log1");
        checkPriority(log1.info, "log1");
        checkPriority(log1.warn, "log1");
        checkPriority(log1.error, "log1");
        
        // make sure context works with the lastLog system
        final logContext = new Logger("test1[context]");
        checkPriority(logContext.verbose, "logContext");
        checkPriority(logContext.info, "logContext");
        checkPriority(logContext.warn, "logContext");
        checkPriority(logContext.error, "logContext");
    }
    
    function testFlags()
    {
        simulateCompileFlags
        ("
            -D log=info
            -D test1.throw=none
            -D test1.log=verbose
        ");
        
        // test global logger
        UAssert.equals(false, Logger.log.verbose.enabled);
        UAssert.equals(true, Logger.log.info.enabled);
        UAssert.equals(true, Logger.log.warn.enabled);
        UAssert.equals(true, Logger.log.error.enabled);
        UAssert.equals(false, Logger.log.verbose.throws);
        UAssert.equals(false, Logger.log.info.throws);
        UAssert.equals(false, Logger.log.warn.throws);
        UAssert.equals(true, Logger.log.error.throws);
        
        // test category
        UAssert.equals(true, log1.verbose.enabled);
        UAssert.equals(true, log1.info.enabled);
        UAssert.equals(true, log1.warn.enabled);
        UAssert.equals(true, log1.error.enabled);
        UAssert.equals(false, log1.verbose.throws);
        UAssert.equals(false, log1.info.throws);
        UAssert.equals(false, log1.warn.throws);
        UAssert.equals(false, log1.error.throws);
        
        simulateCompileFlags
        ("
            -D log=info
            -D test1.throw=none
        ");
        
        // test global logger
        UAssert.equals(false, Logger.log.verbose.enabled);
        UAssert.equals(true, Logger.log.info.enabled);
        UAssert.equals(true, Logger.log.warn.enabled);
        UAssert.equals(true, Logger.log.error.enabled);
        UAssert.equals(false, Logger.log.verbose.throws);
        UAssert.equals(false, Logger.log.info.throws);
        UAssert.equals(false, Logger.log.warn.throws);
        UAssert.equals(true, Logger.log.error.throws);
        
        // test category
        UAssert.equals(false, log1.verbose.enabled);
        UAssert.equals(true, log1.info.enabled);
        UAssert.equals(true, log1.warn.enabled);
        UAssert.equals(true, log1.error.enabled);
        UAssert.equals(false, log1.verbose.throws);
        UAssert.equals(false, log1.info.throws);
        UAssert.equals(false, log1.warn.throws);
        UAssert.equals(false, log1.error.throws);
        
        // specifically test defaults again
        simulateCompileFlags("");
        testDefaults();
    }
    
    function testReuse()
    {
        UAssert.equals(log1, new Logger("test1"));
    }
    
    function testSub()
    {
        simulateCompileFlags
        ("
            -D throw=none
            -D test1.log=warn
            -D test2.log=info
            -D c.log=verbose
            -D test1.c.log=none
            -D b.log=none
        ");
        
        final logA1 = log1.sub("a");
        final logB1 = log1.sub("b");
        final logC1 = log1.sub("c");
        
        final logA2 = log2.sub("a");
        final logB2 = log2.sub("b");
        final logC2 = log2.sub("c");
        
        // -D test1.log=warn
        UAssert.equals(false, log1.verbose.enabled);
        UAssert.equals(false, log1.info.enabled);
        UAssert.equals(true , log1.warn.enabled);
        UAssert.equals(true , log1.error.enabled);
        // -D test2.log=info
        UAssert.equals(false, log2.verbose.enabled);
        UAssert.equals(true , log2.info.enabled);
        UAssert.equals(true , log2.warn.enabled);
        UAssert.equals(true , log2.error.enabled);
        
        // -D test1.log=warn (matches parent)
        UAssert.equals(false, logA1.verbose.enabled);
        UAssert.equals(false, logA1.info.enabled);
        UAssert.equals(true , logA1.warn.enabled);
        UAssert.equals(true , logA1.error.enabled);
        // -D test2.log=info (matches parent)
        UAssert.equals(false, logA2.verbose.enabled);
        UAssert.equals(true , logA2.info.enabled);
        UAssert.equals(true , logA2.warn.enabled);
        UAssert.equals(true , logA2.error.enabled);
        
        // -D b.log=none
        UAssert.equals(false, logB1.verbose.enabled);
        UAssert.equals(false, logB1.info.enabled);
        UAssert.equals(false, logB1.warn.enabled);
        UAssert.equals(false, logB1.error.enabled);
        // -D b.log=none
        UAssert.equals(false, logB2.verbose.enabled);
        UAssert.equals(false, logB2.info.enabled);
        UAssert.equals(false, logB2.warn.enabled);
        UAssert.equals(false, logB2.error.enabled);
        
        // -D test1.c.log=none
        UAssert.equals(false, logC1.verbose.enabled);
        UAssert.equals(false, logC1.info.enabled);
        UAssert.equals(false, logC1.warn.enabled);
        UAssert.equals(false, logC1.error.enabled);
        // -D c.log=verbose
        UAssert.equals(true , logC2.verbose.enabled);
        UAssert.equals(true , logC2.info.enabled);
        UAssert.equals(true , logC2.warn.enabled);
        UAssert.equals(true , logC2.error.enabled);
    }
    
    function testContext()
    {
        final context = new Logger(log1.id + "[context]");
        UAssert.notEquals(log1, context);
    }
    
    function testColor()
    {
        UAssert.equals(new Logger(StyleTools.style(log1.id, RED)), log1);
        
        final sub1 = log1.sub("a");
        final sub2 = log1.sub(StyleTools.style("a", RED));
        UAssert.equals(sub1, sub2);
        
        final context1 = new Logger(log1.id + "[context]");
        final context2 = new Logger(log1.id + StyleTools.style("[context]", RED));
        UAssert.equals(context1, context2);
    }
}
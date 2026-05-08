import debug.Logger;
import haxe.PosInfos;
import utest.Assert as UAssert;

typedef Log = { id:String, priority:String, msg:String, pos:PosInfos };

abstract class Test extends utest.Test
{
    var lastLog:Log;
    
    final reg = ~/(.+?)(?:\[([^\]\[]+)\])?: (.*)/;
    public function setup()
    {
        simulateCompileFlags("");
        
        Logger.globalLog = function (msg, ?pos)
        {
            if (reg.match(msg))
            {
                lastLog = { id: reg.matched(1), priority: reg.matched(2), msg: reg.matched(3), pos:pos };
            }
            else
            {
                throw 'Unable to process log: $msg';
            }
        }
        lastLog = null;
    }
    
    final flagReg = ~/\s*-D\s+(.+?)\s*=\s*(.+)\s*/;
    function simulateCompileFlags(str:String)
    {
        @:privateAccess Logger.list.clear();
        @:privateAccess PriorityList.flagsByID.clear();
        
        final all = LoggerDefines.all;
        all.clear();
        for (line in str.split("\n"))
        {
            if (flagReg.match(line))
                all.set(flagReg.matched(1), flagReg.matched(2));
        }
        
        Logger.log.setPriority(VERBOSE);
        Logger.log.setThrowPriority(ERROR);
        Logger.log.resetFromCompilerFlags();
        initLoggers();
    }
    
    function initLoggers() {}
}
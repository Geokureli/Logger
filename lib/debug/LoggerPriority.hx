package debug;

import debug.Logger;
import haxe.PosInfos;

@:forward(enabled, throws, assert)
abstract LoggerPriority(LoggerPriorityRaw)
{
    public function new(parent, level)
    {
        this = new LoggerPriorityRaw(parent, level);
    }
    
    @:op(a())
    inline function callPos(msg:Any, ?pos:PosInfos)
    {
        this.log(msg, pos);
    }
    
    @:allow(debug.LoggerRaw)
    inline function destroy()
    {
        this.destroy();
    }
}

@:allow(debug.LoggerPriority)
private class LoggerPriorityRaw
{
    var parent:Logger;
    final level:Priority;
    
    public var assert(default, null):Assert;
    
    /** Whether this log level is enabled */
    public var enabled(get, set):Bool;
    inline function get_enabled() @:privateAccess return parent.logEnabled(level);
    inline function set_enabled(value:Bool) @:privateAccess return parent.setLogEnabled(level, value);
    
    /** Whether this log level is set to throw exceptions when called */
    public var throws(get, set):Bool;
    inline function get_throws() @:privateAccess return parent.throwEnabled(level);
    inline function set_throws(value:Bool) @:privateAccess return parent.setThrowEnabled(level, value);
    
    public function new(parent:Logger, level:Priority)
    {
        this.parent = parent;
        this.level = level;
        
        assert = new Assert((?s, ?p)->log(s, p));
    }
    
    public function destroy()
    {
        parent = null;
        @:privateAccess 
        assert.destroy();
    }
    
    function log(msg:Any, ?pos:PosInfos):Void
    {
        @:privateAccess
        parent.logIf(level, msg, pos);
    }
}

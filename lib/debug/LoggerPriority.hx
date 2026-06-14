package debug;

import debug.Logger;
import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

@:forward(enabled, throws, assert, level)
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

    function vFormat(args:Array<Any>, delim = ", "):String
    {
        return args.map(Std.string).join(delim);
    }

    /** Variadic log, allows any number of arguments but cannot specify the pos */
    macro public function v(expr:ExprOf<Bool>, args:Array<Expr>):Expr
    {
        return LoggerPriorityRaw.v(expr, args);
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
    public final level:Priority;
    
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
    
    #if macro
    static public function v(instance:Expr, args:Array<Expr>):Expr
    {
        return macro
        {
            @:pos(instance.pos)
            $instance(@:privateAccess $instance.vFormat([$a{args}]));
        };
    }
    #end
}

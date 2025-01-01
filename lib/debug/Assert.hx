package debug;

import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;

/**
 * A group of tools used to log or throw based on expected conditions. For example to use the
 * global logger's error log to throw an error:
 * ```haxe
 * final username = "JohnnyBoy420";
 * final user = getUserData(username);
 * // Throw an error if user is null
 * Logger.assert(user != null, 'Could not find user data for $username');
 * // Otherwise, check their birthday
 * if (user.birthday == today)
 *     trace('Happy birthday, ${user.fullName}!');
 * ```
 * The above assumes that the global logger is set to throw errors.
 * 
 * Can shorten calls to the global logger via `import debug.Logger.assert`
 */
@:forward
abstract Assert(AssertRaw)
{
    public function new(fail:(String, ?PosInfos)->Void):Void
    {
        this = new AssertRaw(fail);
    }
    
    @:op(a())
    macro public function eval(expr:ExprOf<Bool>, args:Array<Expr>):Expr
    {
        return AssertRaw.eval(expr, args);
    }
}

 @:allow(debug.Logger)
 @:allow(debug.Assert)
class AssertRaw
{
    /**
     * Called by failed asserts, throws an error by default. 
     * Can be redirected to any function.
     * 
     * @example myAssert.fail = haxe.Log.trace;    myAssert.isTrue(false, "test");// output: test
     * 
     * @param msg  An optional error message. If not passed a default one will be used
     */
    public var fail(default, null):(msg:String, ?pos:PosInfos)->Void;
    
    function new(fail:(String, ?PosInfos)->Void):Void
    {
        this.fail = fail;
    }
    
    function destroy()
    {
        fail = null;
    }
    
    /** Logs the message if the condition is not true */
    inline public function isTrue(cond:Bool, ?msg:String, ?pos:PosInfos):Bool
    {
        if (!cond)
            fail(msg ?? 'Expected true, got false', pos);
        
        return cond;
    }
    
    /** Logs the message if the condition is true */
    inline public function isFalse(cond:Bool, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(!cond, 'Expected false, got true', pos);
    }
    
    /** Logs the message if the condition is not null */
    inline public function isNull(value:Dynamic, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(value == null, msg ?? 'Expected null, got ${q(value)}', pos);
    }
    
    /** Logs the message if the condition is null */
    inline public function nonNull(value:Dynamic, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(value != null, msg ?? 'Unexpected null', pos);
    }
    
    /** Logs the message if the map doesn't have the key */
    inline public function exists<K, T>(map:Map<K, T>, key:K, ?msg:String, ?pos:PosInfos):Bool
    {
        return nonNull(map, null, pos) 
            && isTrue(map.exists(key), msg ?? 'Could not find key ${Std.string(key)}', pos);
    }
    
    /** Logs the message if the map has the key */
    inline public function notExists<K, T>(map:Map<K, T>, key:K, ?msg:String, ?pos:PosInfos):Bool
    {
        return nonNull(map, null, pos)
            && isTrue(!map.exists(key), msg ?? 'Unexpected key ${Std.string(key)}', pos);
    }
    
    /** Logs the message if the object doesn't have the field. Uses Reflection */
    inline public function has(object:Dynamic, field:String, ?msg:String, ?pos:PosInfos):Bool
    {
        return nonNull(object, null, pos)
            && isTrue(Reflect.hasField(object, field), msg ?? 'Could not find field $field', pos);
    }
    
    
    /** Logs the message if the map has the field. Uses Reflection */
    inline public function missing(object:Dynamic, field:String, ?msg:String, ?pos:PosInfos):Bool
    {
        return nonNull(object, null, pos)
            && isTrue(!Reflect.hasField(object, field), msg ?? 'Unexpected field $field', pos);
    }
    
    /** Logs the message if the value is not the type */
    inline public function is(value:Dynamic, type:Dynamic, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(Std.isOfType(value, type),
            msg ?? 'Expected type ${typeToString(type)}, found ${typeToString(value)}', pos);
    }
    
    /** Logs the message if the value is the type */
    inline public function isNot(value:Dynamic, type:Dynamic, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(!Std.isOfType(value, type), msg ?? 'Unexpected type ${typeToString(type)}', pos);
    }
    
    /** Logs the message if the value is not a class, class instance, structure or enum */
    inline public function isObject(value:Dynamic, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(Reflect.isObject(value), msg ?? "Expected Object type", pos);
    }
    
    /** Logs the message if the value does not match the expected value */
    inline public function equals(value:Dynamic, expected:Dynamic, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(expected == value, msg ?? 'Expected ${q(expected)}, found ${q(value)}', pos);
    }
    
    /** Logs the message if the value matches the unexpected value */
    inline public function notEquals(value:Dynamic, unexpected:Dynamic, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(value != unexpected,
            msg ?? 'Unexpected ${q(unexpected)} found, should be different', pos);
    }
    
    /** Logs the message if the value doesn't match the pattern */
    inline public function match(pattern:EReg, value:Dynamic, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(pattern.match(value), msg ?? '${q(value)} does not match the provided pattern', pos);
    }
    
    
    /** Logs the message if the value is not *approxamitely* the expected value */
    inline public function floatEquals(value:Float, expected:Float, approx:Float = 1e-5, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(compareFloats(expected, value, approx),
            msg ?? 'Expected ${q(expected)}, found ${q(value)}', pos);
    }
    
    function compareFloats(value:Float, expected:Float, approx:Float):Bool
    {
        if (Math.isNaN(expected))
            return Math.isNaN(value);
        
        if (Math.isNaN(value))
            return false;
        
        if (!Math.isFinite(expected) && !Math.isFinite(value))
            return (expected > 0) == (value > 0);
        
        return Math.abs(value - expected) <= approx;
    }
    
    /** Logs the message if the list doesn't contain the value */
    overload inline extern public function contains<T>(list:Iterable<T>, item:T, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(Lambda.has(list, item), msg ?? 'Couldn\'t find ${item} in ${q(list)}', pos);
    }
    
    /** Logs the message if the list contains the value */
    overload inline extern public function notContains<T>(list:Iterable<T>, item:T, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(!Lambda.has(list, item), msg ?? 'Found unexpected ${item} in ${q(list)}', pos);
    }
    
    /** Logs the message if the string doesn't contain the value */
    overload inline extern public function contains(str:String, token:String, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(str != null && str.indexOf(token) >= 0,
            msg ?? 'String ${q(str)} do not contain ${token}', pos);
    }
    
    /** Logs the message if the string doesn't contain the value */
    overload inline extern public function notContains(str:String, token:String, ?msg:String, ?pos:PosInfos):Bool
    {
        return isTrue(str == null || str.indexOf(token) < 0,
            msg ?? 'Found unexpected ${token} in ${q(str)}', pos);
    }
    
    // =============================================================================
    //{ region                            HELPERS
    // =============================================================================
    
    function typeToString(t:Dynamic):String
    {
        try
        {
            final _t = Type.getClass(t);
            
            if (_t != null)
                t = _t;
            
        }
        catch(e:Dynamic) { }
        
        try return Type.getClassName(t) catch (e:Dynamic) { }
        
        try
        {
            final _t = Type.getEnum(t);
            
            if (_t != null)
                t = _t;
            
        }
        catch(e:Dynamic) { }
        
        try return Type.getEnumName(t)        catch (e:Dynamic) { }
        try return Std.string(Type.typeof(t)) catch (e:Dynamic) { }
        try return Std.string(t)              catch (e:Dynamic) { }
        
        return "<Unknown Type>";
    }
    
    /** Wraps in quotes */
    inline function q(v:Dynamic):String
    {
        if (Std.isOfType(v, String))
            v = '"' + StringTools.replace(v, '"', '\\"') + '"';
        
        return Std.string(v);
    }
    
    //} endregion                         HELPERS
    // =============================================================================
    
    #if macro
    static function eval(instance:Expr, args:Array<Expr>):Expr
    {
        if (args.length == 1)
            return evalFinal(instance, args[0]);
        
        if (args.length == 2)
            return evalFinal(instance, args[0], args[1]);
        
        throw "Invalid number of args";
    }
    
    static function evalFinal(instance:Expr, cond:ExprOf<Bool>, ?msg:ExprOf<String>):Expr
    {
        final formatted = msg
            ?? MacroStringTools.formatString('Assertion failed: ${ExprTools.toString(cond)}', cond.pos);
        
        return macro
        {
            @:pos(cond.pos)
            $instance.isTrue($cond, $formatted);
        };
    }
    #end
}
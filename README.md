# Logger

Tool used to simplify the categorization of logs, and easily customize which type of logs are displayed, and which throw exceptions.

## Creating categories
To create categories, simple instantiate multiple `Logger` instances, like so:

```haxe
static public var combatLog = new Logger("Combat", WARN);
static public var resourceLog = new Logger("Res", INFO);
```

Typically, though, you would give each static class, tool or important object it's own logger, such as `CombatUtil.log` or `myHero.log`. For uncategorized logs, simply use `Logger.log`

## Logging
To log, you can call Logger instances as if they were functions, for example: `Logger.log(imporantInfo);` or `CombatUtil.log("battle started")`, but each logger also has various priorities that are conditionally logged, like `Logger.log.error("Missing asset")` or `CombatUtil.log.verbose("attacked for 5 damage");`. While these log priorities can be called, they too, also have fields. You can disable a certain priority like so: `log.verbose.enabled = false;` or you can make a certain priority throw exceptions instead of logging via: `log.warn.throws = true;`

## Enabling logs via compile flags
While the `Logger` constructor has `priority` and `throwPriority` args, these can be overriden from compiler flags, by adding the flag `-D log=WARN` all log priorities less than `WARN` (i.e.: `INFO` and `VERBOSE`) are disabled. You can also specify exactly which priorities are enabled, for example, `-D log=[info,error]` will disable all priorities other than `INFO` and `ERROR`. The `log` flag will also effect all categories, unless the category has it's own log priorities set in compiler flags. For example, a logger with the id "Combat" can have its log priorities set via `-D combat.log=error`. There is a similar `throw` flag to specify which logs throw an exception
package util.plugins;

import ui.ScriptedMusicBeatState;
import modding.base.ScriptedFlxState;
import polymod.hscript.HScriptedClass;
import scripting.ScriptedScriptEventDispatchState;
import flixel.FlxState;
import scripting.ScriptEventDispatchState;
import flixel.FlxBasic;
import flixel.FlxG;
import modding.PolymodManager;


/**
 * A plugin that binds a set of keybinds to allow the user to re-load assets.
 */
class ReloadAssetsPlugin extends FlxBasic
{
    public override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.F5)
        {
            reload();
        }
    }

    public static function reload():Void
    {
        var extendedDispatchedStatesList = [];

        // Query the list of scripted states.
        @:privateAccess
        extendedDispatchedStatesList = polymod.hscript._internal.PolymodScriptClass.listScriptClassesExtendingClass(ScriptEventDispatchState);

        // Check if this is a scripted state.
        var isScripted:Bool = FlxG.state is ScriptedFlxState || FlxG.state is ScriptedMusicBeatState || FlxG.state is ScriptedScriptEventDispatchState;

        if (isScripted)
        {
            // First, retrieve the scripted class name.
            var name:String = '';
            
            switch (true)
            {
                case (FlxG.state is ScriptedFlxState) => true:
                    var s:ScriptedFlxState = cast FlxG.state;

                    @:privateAccess name = s._asc.fullyQualifiedName;
                case (FlxG.state is ScriptedMusicBeatState) => true:
                    var s:ScriptedMusicBeatState = cast FlxG.state;
                    
                    @:privateAccess name = s._asc.fullyQualifiedName;
                case (FlxG.state is ScriptedScriptEventDispatchState) => true:
                    var s:ScriptedScriptEventDispatchState = cast FlxG.state;
                    
                    @:privateAccess name = s._asc.fullyQualifiedName;
                default:
            }

            if (name != '')
            {
                // If this scripted class is a ScriptDispatchEvent state, handling asset reloading through this script class.
                if (extendedDispatchedStatesList.contains(name))
                {
                    trace('Attempting asset hot-reloading through scripted class $name');
                    switch (true)
                    {
                        case (FlxG.state is ScriptedMusicBeatState) => true:
                            var s:ScriptedMusicBeatState = cast FlxG.state;
                            s.reloadAssets();
                        case (FlxG.state is ScriptedScriptEventDispatchState) => true:
                            var s:ScriptedScriptEventDispatchState = cast FlxG.state;
                            s.reloadAssets();
                        default:
                    }
                }
                else
                {
                    trace('Attempting asset hot-reloading while creating scripted class $name');
                    
                    // Load a new script class instance through here.
                    PolymodManager.reloadAssets();

                    var state:Dynamic = ScriptedFlxState.scriptInit(name);
                    FlxG.switchState(state);
                }
            }
        }
        else
        {
            // Hot-reload normally.
            var dispatchState:ScriptEventDispatchState = cast FlxG.state;
            if (dispatchState != null)
            {
                dispatchState.reloadAssets();
            }
            else
            {
                PolymodManager.reloadAssets();
                FlxG.resetState();
            }
        }
    }
}
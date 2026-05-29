package play.dialogue;

import polymod.hscript.HScriptedClass;

@:hscriptClass
class ScriptedDialogue extends Dialogue implements HScriptedClass
{
	public function new(id:String)
	{
		super(id);
	}

	public static function scriptInit(scriptClass:Dynamic, id:String):Dialogue
	{
		if (scriptClass != null)
		{
			try
			{
				var cls:Class<Dynamic> = null;

				if (Std.isOfType(scriptClass, String))
					cls = Type.resolveClass(cast scriptClass);
				else
					cls = cast scriptClass;

				if (cls != null)
				{
					var created:Dynamic = Type.createInstance(cls, [id]);
					if (Std.isOfType(created, Dialogue))
						return cast created;
				}
			}
			catch (e:Dynamic)
			{
				trace('[ScriptedDialogue] Failed to create scripted dialogue: ' + Std.string(e));
			}
		}

		return new ScriptedDialogue(id);
	}

	public static function listScriptClasses():Array<String>
	{
		return [];
	}
}

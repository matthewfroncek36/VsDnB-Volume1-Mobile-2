package play.dialogue;

import polymod.hscript.HScriptedClass;

@:hscriptClass
class ScriptedSpeaker extends Speaker implements HScriptedClass
{
	public static function scriptInit(scriptClass:Dynamic, id:String):Speaker
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
					if (Std.isOfType(created, Speaker))
						return cast created;
				}
			}
			catch (e:Dynamic)
			{
				trace('[ScriptedSpeaker] Failed to create scripted speaker: ' + Std.string(e));
			}
		}

		return new Speaker(id);
	}
}

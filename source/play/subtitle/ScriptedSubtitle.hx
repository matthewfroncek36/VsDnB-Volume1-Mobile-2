package play.subtitle;

import data.subtitle.SubtitleData;
import polymod.hscript.HScriptedClass;

@:hscriptClass
class ScriptedSubtitle extends play.subtitle.Subtitle implements HScriptedClass
{
	public static function scriptInit(scriptClass:Dynamic, data:SubtitleData, manager:SubtitleManager):Subtitle
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
					var created:Dynamic = Type.createInstance(cls, [data, manager]);
					if (Std.isOfType(created, Subtitle))
						return cast created;
				}
			}
			catch (e:Dynamic)
			{
				trace('[ScriptedSubtitle] Failed to create scripted subtitle: ' + Std.string(e));
			}
		}

		return new Subtitle(data, manager);
	}
}

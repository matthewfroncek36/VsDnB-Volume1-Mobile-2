package play.stage;

import data.stage.StageData;
import polymod.hscript.HScriptedClass;

@:hscriptClass
class ScriptedStage extends Stage implements HScriptedClass
{
	public function new(data:StageData)
	{
		super(data);
	}

	public static function scriptInit(scriptClass:Dynamic, data:StageData):Stage
	{
		if (scriptClass != null)
		{
			try
			{
				var created:Dynamic = Type.createInstance(scriptClass, [data]);
				if (Std.isOfType(created, Stage))
					return cast created;
			}
			catch (e:Dynamic)
			{
				trace('[ScriptedStage] Failed to create scripted stage: ' + Std.string(e));
			}
		}

		return new Stage(data);
	}
}

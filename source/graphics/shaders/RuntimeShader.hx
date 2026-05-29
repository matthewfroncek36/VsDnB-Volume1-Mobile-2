package graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;

/**
 * A shader that's generated at runtime instead of being complied.
 */
class RuntimeShader extends FlxRuntimeShader
{
	public function new(fragmentSource:String, ?vertexSource:String)
	{
		#if SHADERS_ENABLED
		var fragSource:String = Assets.getText(fragmentSource);

		var vertSource:Null<String> = null;
		if (vertexSource != null)
			vertSource = Assets.getText(vertexSource);
		#else
		var fragSource:String = '';
		var vertSource:String = '';
		#end
		super(fragSource, vertSource);
	}
}

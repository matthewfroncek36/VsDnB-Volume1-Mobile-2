package graphics;

import animate.FlxAnimate;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMatrix;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.graphics.frames.FlxFrame;
import openfl.geom.ColorTransform;
import openfl.utils.Assets;

/**
 * An FlxSprite rendered through an FlxAnimate.
 * Used to help implement sprites that are texture atlas.
 */
class FlxAtlasSprite extends FlxAnimate
{
	/**
	 * Dispatched when an animation is played.
	 */
	public var onStart(default, null):FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

	/**
	 * Plays a given animation.
	 * @param name The name of the animation to play.
	 * @param force Whether this animation to play immediately, or wait till the current one's finished.
	 * @param reverse Should this animation start from the end?
	 * @param frame The frame of the animation to start on.
	 */
	public function playAnimation(name:String, force:Bool = false, reverse:Bool = false, frame:Int = 0)
	{
		if ([null, ''].contains(name))
			return;

		animation.play(name, force, reverse, frame);

		onStart.dispatch(name);
	}

	/**
	 * Adds a new animation by the prefix.
	 * @param name The name to call the animation.
	 * @param prefix The prefix of the animation to add.
	 * @param frameRate The frame rate the animation should be.
	 * @param looped Should this animation restart when finished?
	 */
	public inline function addByPrefix(name:String, prefix:String, frameRate:Int, looped:Bool)
	{
		anim.addBySymbol(name, prefix, frameRate, looped);
	}

	/**
	 * Adds a new animation based on a given animation's list of frames.
	 * @param name The name to call the animation.
	 * @param prefix The prefix of the animation to add.
	 * @param frameRate The frame rate the animation should be.
	 * @param looped Should this animation restart when finished?
	 * @param Indices A list of frames to build the animation on.
	 */
	public inline function addByIndices(name:String, prefix:String, frameRate:Int, looped:Bool = false, Indices:Array<Int>)
	{
		anim.addBySymbolIndices(name, prefix, Indices, frameRate, looped);
	}

	/**
	 * Removes a given animation from the sprite.
	 * @param name The name of the animation to remove.
	 * @return Whether the animation was able to be successfully removed.
	 */
	public inline function remove(name:String):Bool
	{
		if (animation.exists(name))
		{
			anim.remove(name);
			return true;
		}
		return false;
	}
}
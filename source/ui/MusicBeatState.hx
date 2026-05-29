package ui;

import backend.Conductor;
import controls.Controls;
import controls.PlayerSettings;
import data.song.SongData.SongTimeChange;
import flixel.FlxG;
import scripting.ScriptEventDispatchState;
import scripting.events.ScriptEvent;
import scripting.module.ModuleHandler;
import util.SortUtil;
import flixel.FlxCamera;
import flixel.FlxBasic;
import mobile.MobileData;
import mobile.IMobileControls;
import mobile.Hitbox;
import mobile.TouchPad;
import flixel.util.FlxDestroyUtil;
import play.save.Preferences;

/**
 * An `FlxState` linked to the Conductor to allow for bpm synced events such as step, beat, and measure hit events, and more.
 */
class MusicBeatState extends ScriptEventDispatchState
{
	/**
	 * The current step of the Conductor.
	 */
	private var curStep(get, never):Int;

	function get_curStep():Int
		return Conductor.instance.curStep;

	public var touchPad:TouchPad;
	public var touchPadCam:FlxCamera;
	public var mobileControls:IMobileControls;
	public var mobileControlsCam:FlxCamera;

	public function addTouchPad(DPad:String, Action:String)
	{
		touchPad = new TouchPad(DPad, Action);
		add(touchPad);
	}

	public function removeTouchPad()
	{
		if (touchPad != null)
		{
			remove(touchPad);
			touchPad = FlxDestroyUtil.destroy(touchPad);
		}

		if(touchPadCam != null)
		{
			FlxG.cameras.remove(touchPadCam);
			touchPadCam = FlxDestroyUtil.destroy(touchPadCam);
		}
	}

	public function addMobileControls(defaultDrawTarget:Bool = false):Void
	{
		var extraMode = MobileData.extraActions.get(Preferences.extraButtons);

		switch (MobileData.mode)
		{
			case 0: // RIGHT_FULL
				mobileControls = new TouchPad('RIGHT_FULL', 'NONE', extraMode);
			case 1: // LEFT_FULL
				mobileControls = new TouchPad('LEFT_FULL', 'NONE', extraMode);
			case 2: // CUSTOM
				mobileControls = MobileData.getTouchPadCustom(new TouchPad('RIGHT_FULL', 'NONE', extraMode));
			case 3: // HITBOX
				mobileControls = new Hitbox(extraMode);
		}

		mobileControlsCam = new FlxCamera();
		mobileControlsCam.bgColor.alpha = 0;
		FlxG.cameras.add(mobileControlsCam, defaultDrawTarget);

		mobileControls.instance.cameras = [mobileControlsCam];
		mobileControls.instance.visible = false;
		add(mobileControls.instance);
	}

	public function removeMobileControls()
	{
		if (mobileControls != null)
		{
			remove(mobileControls.instance);
			mobileControls.instance = FlxDestroyUtil.destroy(mobileControls.instance);
			mobileControls = null;
		}

		if (mobileControlsCam != null)
		{
			FlxG.cameras.remove(mobileControlsCam);
			mobileControlsCam = FlxDestroyUtil.destroy(mobileControlsCam);
		}
	}

	public function addTouchPadCamera(defaultDrawTarget:Bool = false):Void
	{
		if (touchPad != null)
		{
			touchPadCam = new FlxCamera();
			touchPadCam.bgColor.alpha = 0;
			FlxG.cameras.add(touchPadCam, defaultDrawTarget);
			touchPad.cameras = [touchPadCam];
		}
	}
	
	/**
	 * The current beat of the Conductor.
	 */
	private var curBeat(get, never):Int;

	function get_curBeat():Int
		return Conductor.instance.curBeat;

	/**
	 * The current measure of the Conductor.
	 */
	private var curMeasure(get, never):Int;

	function get_curMeasure():Int
		return Conductor.instance.curMeasure;

	/**
	 * Alias for the user's controls.
	 */
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.controls;


	override function create()
	{
		addSignals();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		dispatchEvent(new UpdateScriptEvent(elapsed));
	}

	override function destroy()
	{
		removeSignals();
		
		removeTouchPad();
		removeMobileControls();

		super.destroy();
	}

	/**
	 * Calls a script event to the given script functions.
	 * @param event The script event to dispatch.
	 */
	override function dispatchEvent(event:ScriptEvent)
	{
		ModuleHandler.callEvent(event);
	}

	function addSignals():Void
	{
		Conductor.instance.onStepHit.add(stepHit);
		Conductor.instance.onBeatHit.add(beatHit);
		Conductor.instance.onMeasureHit.add(measureHit);
		Conductor.instance.onTimeChangeHit.add(timeChange);
	}
	
	function removeSignals():Void
	{
		Conductor.instance.onStepHit.remove(stepHit);
		Conductor.instance.onBeatHit.remove(beatHit);
		Conductor.instance.onMeasureHit.remove(measureHit);
		Conductor.instance.onTimeChangeHit.remove(timeChange);
	}

	public function stepHit(step:Int):Bool
	{
		var event = new ConductorScriptEvent(STEP_HIT, step, curBeat, curMeasure, Conductor.instance.currentTimeChange);
		dispatchEvent(event);
		
		if (event.eventCanceled) 
			return false;

		return true;
	}

	public function beatHit(beat:Int):Bool
	{
		var event = new ConductorScriptEvent(BEAT_HIT, curStep, beat, curMeasure, Conductor.instance.currentTimeChange);
		dispatchEvent(event);

		if (event.eventCanceled) 
			return false;

		return true;
	}

	public function measureHit(measure:Int):Bool 
	{
		var event = new ConductorScriptEvent(MEASURE_HIT, curStep, curBeat, measure, Conductor.instance.currentTimeChange);
		dispatchEvent(event);

		if (event.eventCanceled) 
			return false;

		return true;
	}

	public function timeChange(timeChange:SongTimeChange):Bool
	{
		var event = new ConductorScriptEvent(TIME_CHANGE_HIT, curStep, curBeat, curMeasure, timeChange);
		dispatchEvent(event);

		if (event.eventCanceled) 
			return false;

		return true;
	}

	public function refresh():Void
	{
		sort(SortUtil.byZIndex);
	}
	
	public static function getState():MusicBeatState
	{
		return cast FlxG.state;
	}
}

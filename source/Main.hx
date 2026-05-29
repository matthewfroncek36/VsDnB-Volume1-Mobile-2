package;

import audio.GameSoundTray;
import backend.debug.FPSDisplay;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import graphics.GameCameraFrontEnd;
import openfl.Lib;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.text.TextFormat;
import haxe.io.Path;
import lime.system.System;

import ui.intro.InitState;

#if desktop
import api.ALSoftConfig; // Longest yeah boi ever
#end

class Main extends Sprite
{
	public static var VERSION:String = '1.0.9';
	
	public static var frameRate:Int = 60;

	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	
	var initialState:Class<FlxState> = InitState;
	var zoom:Float = -1;

	var startFullscreen:Bool = false;

	public static var fps:FPSDisplay;

	public static var applicationName:String = "VS. Dave and Bambi";

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end
	}

	public function new()
	{
		#if android
		Sys.setCwd(Path.addTrailingSlash(android.content.Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(System.documentsDirectory);
		#end
		
		super();
		stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	public static function toggleFuckedFPS(toggle:Bool)
	{
		fps.fuckFps = toggle;
	}

	private function setupGame():Void
	{
		modding.PolymodManager.initalize();

		fps = new FPSDisplay(10, 3, 0xFFFFFF);
		var fpsFormat = new TextFormat("Comic Sans MS Bold", 15, 0xFFFFFF, true);
		fps.defaultTextFormat = fpsFormat;

		var game = new FlxGame(gameWidth, gameHeight, initialState, frameRate, frameRate, true, startFullscreen);

		@:privateAccess
		game._customSoundTray = GameSoundTray;

		@:privateAccess
		untyped FlxG.cameras = new GameCameraFrontEnd();

		addChild(game);
		FlxG.game.addChild(fps);
		
		#if android
		FlxG.android.preventDefaultKeys = [BACK]; 
		#end
	}
}

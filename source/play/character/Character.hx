package play.character;

import backend.Conductor;
import controls.PlayerSettings;
import data.IRegistryEntry;
import data.animation.Animation;
import data.character.CharacterData;
import data.character.CharacterRegistry;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.utils.Assets;
import play.notes.Note;
import scripting.IScriptedClass.IPlayStateScriptedClass;
import scripting.events.*;

using StringTools;

/**
 * Extra character atlas sheet information.
 */
typedef CharacterSheet =
{
	var path:String;
	var anims:Array<Animation>;
	var ?offsetFile:String;
}

/**
 * Defines how this character behaves in-game.
 */
enum CharacterType
{
	PLAYER;
	OPPONENT;
	GF;
	OTHER;
}

/**
 * Base character used by players, opponents, GF, and background props.
 */
class Character extends FlxSprite implements IRegistryEntry<CharacterData> implements IPlayStateScriptedClass
{
	// DATA
	public final id:String;
	public var _data:CharacterData;

	public var characterName(get, never):String;
	function get_characterName():String
	{
		return _data != null && _data.name != null ? _data.name : 'Unknown';
	}

	public var characterIcon(get, never):String;
	function get_characterIcon():String
	{
		return _data != null && _data.icon != null ? _data.icon : id;
	}

	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	public var globalOffset:Array<Float> = [];
	public var cameraOffset:Array<Float> = [];
	public var characterColor:FlxColor = FlxColor.WHITE;
	public var danceSnap:Int = 2;
	public var singDuration:Float = 4;
	public var countdownGraphicType:String = 'normal';
	public var countdownSoundType:String = 'default';
	public var skins:Map<String, String> = new Map<String, String>();
	public var sheetsInUse(default, null):Array<CharacterSheet> = [];

	// GENERAL
	public var characterType:CharacterType = CharacterType.PLAYER;
	public var debugMode:Bool = false;

	public var conductor(get, set):Conductor;
	function get_conductor():Conductor
	{
		return _conductor == null ? Conductor.instance : _conductor;
	}
	function set_conductor(value:Conductor):Conductor
	{
		removeConductor(_conductor == null ? Conductor.instance : _conductor);
		setupConductor(value);
		return _conductor = value;
	}
	var _conductor:Conductor;

	public var cameraNoteOffset:FlxPoint = FlxPoint.get();
	public var cameraFocusPoint(default, null):FlxPoint = FlxPoint.get();
	public var isDead:Bool = false;
	public var startsCountdown:Bool = false;

	// SCALING
	public var baseScale:Float = 1;
	public var offsetScale:Float = 1.0;
	public var scaleOffset(default, null):FlxPoint = FlxPoint.get();

	// DANCING
	public var canDance:Bool = true;
	public var onDance:FlxSignal = new FlxSignal();
	public var danceTypes:Array<String> = ['idle'];
	public var altDanceSuffix:String = '';
	private var danced:Bool = false;

	// SINGING
	public var onSing:FlxTypedSignal<String->Bool->Void> = new FlxTypedSignal<String->Bool->Void>();
	public var canSing:Bool = true;
	public var altSingSuffix:String = '';
	public var holdTimer:Float = 0;
	public var nativelyPlayable:Bool = false;

	/**
	 * Alias for CharacterRegistry.instance.fetchEntry(id).
	 */
	@:allow(play.character.FlareonCharacter)
	public static function create(?x:Float = 0, ?y:Float = 0, id:String, ?characterType:CharacterType = CharacterType.OTHER):Character
	{
		var char:Character = CharacterRegistry.instance.fetchEntry(id);
		char.characterType = characterType;
		char.setPosition(x, y);
		ScriptEventDispatcher.callEvent(char, new ScriptEvent(CREATE, false));
		return char;
	}

	@:allow(play.character.FlareonCharacter)
	public function new(id:String)
	{
		super(0, 0);

		this.id = id;
		_data = fetchData(id);

		if (_data != null)
		{
			this.globalOffset = _data.globalOffset != null ? _data.globalOffset.copy() : [0, 0];
			this.danceSnap = _data.danceSnap;
			this.singDuration = _data.singDuration;
			this.characterColor = FlxColor.fromString(_data.color);
			this.countdownGraphicType = _data.countdownData != null ? _data.countdownData.graphicPath : 'normal';
			this.countdownSoundType = _data.countdownData != null ? _data.countdownData.soundPath : 'default';
			this.antialiasing = _data.antialiasing;
			this.nativelyPlayable = _data.nativelyPlayable;
			this.flipX = _data.flipX;
		}

		skins.set('normal', id);
		skins.set('gfSkin', 'gf-none');
		skins.set('noteSkin', 'normal');
		skins.set('deathSkin', 'generic-death');
	}

	@:allow(play.character.FlareonCharacter)
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (animation == null || animation.curAnim == null) return;
		if (debugMode || isDead) return;

		if (justPressedNote() && characterType == CharacterType.PLAYER)
			holdTimer = 0;

		if (animation.finished && !isSinging() && !isLoopAnimation())
			playLoopingAnimation();

		var shouldStopSinging:Bool = (characterType == CharacterType.PLAYER) ? !isHoldingNote() : true;

		if (!isSingAnimation(animation.curAnim.name) && !isDanceAnimation(animation.curAnim.name) && !animation.finished)
			shouldStopSinging = false;

		if (isSinging())
		{
			holdTimer += elapsed;
			var singTimeSteps:Float = (conductor.stepCrochet / 1000) * singDuration;

			if (holdTimer >= singTimeSteps && shouldStopSinging)
			{
				var currentBaseAnimation:String = fetchBaseAnimationName(animation.curAnim.name);

				if (hasEase(currentBaseAnimation))
				{
					if (!isEaseAnimation())
					{
						holdTimer = 0;
						playAnim(currentBaseAnimation + '-ease', true);
					}
				}
				else
				{
					holdTimer = 0;
					dance(true);
				}
			}
		}
		else
			holdTimer = 0;
	}

	override function destroy():Void
	{
		if (onDance != null)
		{
			onDance.removeAll();
			onDance.destroy();
			onDance = null;
		}

		if (onSing != null)
		{
			onSing.removeAll();
			onSing.destroy();
			onSing = null;
		}

		if (scaleOffset != null) scaleOffset.put();
		if (cameraNoteOffset != null) cameraNoteOffset.put();
		if (cameraFocusPoint != null) cameraFocusPoint.put();

		removeConductor(conductor);
		super.destroy();
	}

	override function toString():String
	{
		return 'Character(id = $id, name=$characterName, type=$characterType)';
	}

	public function onCreate(event:ScriptEvent):Void
	{
		if (animation != null)
		{
			animation.onFinish.add(function(anim:String)
			{
				var currentAnimation:String = fetchBaseAnimationName(anim);

				if (isLoopAnimation(anim)) return;
				if (hasLoopAnimation(currentAnimation)) return;

				if (hasEase(currentAnimation) && isEaseAnimation(anim))
				{
					holdTimer = 0;
					dance(true);
				}
			});
		}

		setupConductor(conductor);
		load();

		if (_data != null)
		{
			this.setScale(_data.scale, _data.scale);
			this.baseScale = _data.scale;
		}

		dance(true);
		updateHitbox();
		resetCameraFocusPoint();

		if (characterType == CharacterType.PLAYER)
			this.flipX = !flipX;
	}

	function load():Void {}

	public function fetchData(id:String):CharacterData
	{
		return CharacterRegistry.instance.fetchData(id);
	}

	public function addCharAtlas(path:String, animations:Array<Animation>, ?offsetFile:String):Void
	{
		if (frames == null)
			frames = Paths.getSparrowAtlas(path);
		else
			cast(frames, FlxAtlasFrames).addAtlas(Paths.getSparrowAtlas(path));

		for (i in animations)
			Animation.addToSprite(this, i);

		if (offsetFile != null)
			loadOffsetFile(offsetFile);

		sheetsInUse.push({path: path, anims: animations, offsetFile: offsetFile});
	}

	@:allow(play.character.FlareonCharacter)
	public function dance(force:Bool = false):Void
	{
		if (!canDance) return;

		if (!force && animation != null)
		{
			var currentAnimation:String = animation.curAnim != null ? animation.curAnim.name : '';

			if (hasEase(currentAnimation)) return;
			if (isSinging()) return;
			if (!isSingAnimation(currentAnimation) && !isDanceAnimation(currentAnimation) && animation.curAnim != null && !animation.finished)
				return;
		}

		cameraNoteOffset.set();
		playDanceAnimation(force);
		onDance.dispatch();
	}

	public function playDanceAnimation(force:Bool = false):Void
	{
		if (danceTypes.contains('alternate'))
		{
			danced = !danced;
			playAnim(danced ? 'danceRight' : 'danceLeft', true);
		}
		else
			playAnim('idle', true);
	}

	@:allow(play.character.FlareonCharacter)
	public function sing(direction:Int, ?miss:Bool = false, ?alt:String = '', ?singArray:Array<String>):Void
	{
		if (singArray == null)
			singArray = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

		if (direction < 0 || direction >= singArray.length)
			return;

		var noteToPlay:String = singArray[direction];
		holdTimer = 0;

		if ((characterType == CharacterType.PLAYER && !nativelyPlayable) || (characterType == CharacterType.OPPONENT && nativelyPlayable))
		{
			noteToPlay = switch (noteToPlay)
			{
				case 'LEFT': 'RIGHT';
				case 'RIGHT': 'LEFT';
				default: noteToPlay;
			};
		}

		if (miss)
			noteToPlay += 'miss';

		playAnim('sing${noteToPlay}' + alt, true);
		onSing.dispatch(noteToPlay, miss);
	}

	@:allow(play.character.FlareonCharacter)
	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		if (animation == null || !animation.exists(name) || (isDanceAnimation(name) && !canDance) || (isSingAnimation(name) && !canSing))
			return;

		if (altDanceSuffix != '' && !name.contains(altDanceSuffix) && isDanceAnimation(name.toLowerCase()))
			name += altDanceSuffix;

		if (altSingSuffix != '' && !name.contains(altSingSuffix) && isSingAnimation(name.toLowerCase()))
			name += altSingSuffix;

		if (!animation.exists(name))
			return;

		animation.play(name, force, reversed, frame);

		if (animOffsets.exists(name))
		{
			var daOffset:Array<Float> = animOffsets.get(name);
			offset.set((daOffset[0] * offsetScale) + scaleOffset.x, (daOffset[1] * offsetScale) + scaleOffset.y);
		}
		else
			offset.set(scaleOffset.x, scaleOffset.y);
	}

	@:allow(play.character.FlareonCharacter)
	public function playLoopingAnimation(?name:String, force:Bool = true):Void
	{
		if (animation == null)
			return;

		if (name == null)
			name = animation.curAnim != null ? animation.curAnim.name : '';

		var currentAnimation:String = fetchBaseAnimationName(name);

		if (animation.exists(currentAnimation + '-loop'))
			playAnim(currentAnimation + '-loop', force);
	}

	public function onOpponentNoteHit(event:NoteScriptEvent):Void {}
	public function onPlayerNoteHit(event:NoteScriptEvent):Void {}

	@:allow(play.character.FlareonCharacter)
	public function onNoteMiss(event:NoteScriptEvent):Void
	{
		if (event.eventCanceled || event.note.character != this)
			return;

		switch (characterType)
		{
			case GF:
				playAnim('sad', true);
			case PLAYER:
				var note:Note = event.note;
				this.sing(note.direction, true);
			default:
		}
	}

	@:allow(play.character.FlareonCharacter)
	public function onGhostNoteMiss(event:GhostNoteScriptEvent):Void
	{
		if (event.eventCanceled || event.character != this)
			return;

		switch (characterType)
		{
			case GF:
				playAnim('sad', true);
			case PLAYER:
				this.sing(event.direction, true);
			default:
		}
	}

	@:allow(play.character.FlareonCharacter)
	public function onHoldNoteDrop(event:HoldNoteScriptEvent):Void
	{
		if (event.eventCanceled || event.character != this)
			return;

		switch (characterType)
		{
			case GF:
				playAnim('sad', true);
			case PLAYER:
				this.sing(event.holdNote.direction, true);
			default:
		}
	}

	public function playComboAnimation(combo:Int):Void
	{
		if (combo % 100 == 0 && animation != null && animation.exists('cheer'))
		{
			canDance = false;
			playAnim('cheer', true);

			animation.onFinish.addOnce(function(anim:String)
			{
				canDance = true;
			});
		}
	}

	@:allow(play.character.FlareonCharacter)
	public function fetchBaseAnimationName(name:String):String
	{
		if (name == null)
			return '';

		for (suffix in ['-loop', '-ease'])
		{
			if (name.contains(suffix))
				name = name.substring(0, name.lastIndexOf(suffix));
		}

		return name;
	}

	public function setScale(x:Float, y:Float):Void
	{
		scale.set(baseScale * x, baseScale * y);
		width = Math.abs(baseScale * x) * frameWidth;
		height = Math.abs(baseScale * y) * frameHeight;
		scaleOffset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		resetCameraFocusPoint();
	}

	public function resetCameraFocusPoint():Void
	{
		var camX:Float = 0;
		var camY:Float = 0;

		if (_data != null && _data.cameraOffsets != null && _data.cameraOffsets.length >= 2)
		{
			camX = _data.cameraOffsets[0];
			camY = _data.cameraOffsets[1];
		}

		cameraFocusPoint.x = x + (width / 2) + camX;
		cameraFocusPoint.y = y + (height / 2) + camY;
	}

	public function flip():Void
	{
		flipX = !flipX;
		nativelyPlayable = !nativelyPlayable;
	}

	public function reposition():Void
	{
		if (globalOffset != null && globalOffset.length >= 2)
		{
			x += globalOffset[0];
			y += globalOffset[1];
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
	{
		animOffsets[name] = [x, y];
	}

	function loadOffsetFile(character:String):Void
	{
		if (character == null || character.length < 1)
			return;

		if (!Assets.exists(Paths.offsetFile(character), TEXT))
			return;

		var offsetData:Array<String> = Assets.getText(Paths.offsetFile(character)).trim().split('\n');

		for (offsetText in offsetData)
		{
			offsetText = offsetText.trim();

			if (offsetText.length < 1)
				continue;

			var offsetInfo:Array<String> = offsetText.split(' ');

			if (offsetInfo.length >= 3)
				addOffset(offsetInfo[0], Std.parseFloat(offsetInfo[1]), Std.parseFloat(offsetInfo[2]));
		}
	}

	public function removeConductor(input:Conductor):Void
	{
		if (input == null)
			return;

		input.onStepHit.remove(stepHit);
		input.onBeatHit.remove(beatHit);
		input.onMeasureHit.remove(measureHit);
	}

	public function setupConductor(input:Conductor):Void
	{
		if (input == null)
			return;

		input.onStepHit.add(stepHit);
		input.onBeatHit.add(beatHit);
		input.onMeasureHit.add(measureHit);
	}

	public function hasEase(?name:String):Bool
	{
		if (animation == null)
			return false;

		if (name == null)
			name = animation.curAnim != null ? animation.curAnim.name : '';

		return animation.exists(name + '-ease');
	}

	public function hasLoopAnimation(?name:String):Bool
	{
		if (animation == null)
			return false;

		if (name == null)
			name = animation.curAnim != null ? animation.curAnim.name : '';

		name = fetchBaseAnimationName(name);
		return animation.exists(name + '-loop');
	}

	public function isSinging():Bool
	{
		return isSingAnimation(animation != null && animation.curAnim != null ? animation.curAnim.name : '');
	}

	public function isDancing():Bool
	{
		return isDanceAnimation(animation != null && animation.curAnim != null ? animation.curAnim.name : '');
	}

	function isSingAnimation(?name:String):Bool
	{
		return name != null && name.startsWith('sing');
	}

	function isDanceAnimation(?name:String):Bool
	{
		return name != null && (name.startsWith('idle') || name.startsWith('dance'));
	}

	public function isLoopAnimation(?name:String):Bool
	{
		if (name == null)
			name = animation != null && animation.curAnim != null ? animation.curAnim.name : '';

		return name.endsWith('-loop');
	}

	public function isEaseAnimation(?name:String):Bool
	{
		if (name == null)
			name = animation != null && animation.curAnim != null ? animation.curAnim.name : '';

		return name.endsWith('-ease');
	}

	function isHoldingNote():Bool
	{
		return PlayerSettings.controls.LEFT || PlayerSettings.controls.DOWN || PlayerSettings.controls.UP || PlayerSettings.controls.RIGHT;
	}

	function justPressedNote():Bool
	{
		return PlayerSettings.controls.LEFT_P || PlayerSettings.controls.DOWN_P || PlayerSettings.controls.UP_P || PlayerSettings.controls.RIGHT_P;
	}

	function getDataFlipX():Bool
	{
		return _data != null ? _data.flipX : false;
	}

	function stepHit(step:Int):Void {}
	function beatHit(beat:Int):Void
	{
		if (danceSnap != 0 && beat % danceSnap == 0 && canDance)
			dance();
	}
	function measureHit(measure:Int):Void {}

	override function set_x(value:Float):Float
	{
		var diff:Float = value - x;
		cameraFocusPoint.x += diff;
		return super.set_x(value);
	}

	override function set_y(value:Float):Float
	{
		var diff:Float = value - y;
		cameraFocusPoint.y += diff;
		return super.set_y(value);
	}

	override function set_flipX(value:Bool):Bool
	{
		animOffsets.clear();

		if (_data != null)
		{
			var flipped:Bool = value != getDataFlipX();
			loadOffsetFile(flipped ? _data.offsetFilePlayer : _data.offsetFileOpponent);
		}

		return super.set_flipX(value);
	}

	// Script hooks
	public function onScriptEvent(event:ScriptEvent):Void {}
	public function onScriptEventPost(event:ScriptEvent):Void {}
	public function onUpdate(event:UpdateScriptEvent):Void {}
	public function onDestroy(event:ScriptEvent):Void {}
	public function onNoteSpawn(event:NoteScriptEvent):Void {}
	public function onPreferenceChanged(event:PreferenceScriptEvent):Void {}
	public function onStepHit(event:ConductorScriptEvent):Void {}
	public function onBeatHit(event:ConductorScriptEvent):Void {}
	public function onMeasureHit(event:ConductorScriptEvent):Void {}
	public function onTimeChangeHit(event:ConductorScriptEvent):Void {}
	public function onCreatePost(event:ScriptEvent):Void {}
	public function onCreateUI(event:ScriptEvent):Void {}
	public function onSongStart(event:ScriptEvent):Void {}
	public function onSongLoad(event:ScriptEvent):Void {}
	public function onSongEnd(event:ScriptEvent):Void {}
	public function onPause(event:ScriptEvent):Void {}
	public function onResume(event:ScriptEvent):Void {}
	public function onPressSeven(event:ScriptEvent):Void {}
	public function onGameOver(event:ScriptEvent):Void {}
	public function onCountdownStart(event:CountdownScriptEvent):Void {}
	public function onCountdownTick(event:CountdownScriptEvent):Void {}
	public function onCountdownTickPost(event:CountdownScriptEvent):Void {}
	public function onCountdownFinish(event:CountdownScriptEvent):Void {}
	public function onCameraMove(event:CameraScriptEvent):Void {}
	public function onCameraMoveSection(event:CameraScriptEvent):Void {}
}

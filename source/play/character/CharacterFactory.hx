package play.character;

class CharacterFactory
{
	public static function create(x:Float, y:Float, ?character:String = '', ?isPlayer:Bool = false):Character
	{
		var characterId:String = (character == null || character.length < 1) ? "bf" : character;

		return switch (characterId.toLowerCase())
		{
			case "flareon", "flareon-png", "flareon-rig":
				new FlareonCharacter(x, y, characterId, isPlayer);
			default:
				Character.create(x, y, characterId, isPlayer ? PLAYER : OPPONENT);
		}
	}
}

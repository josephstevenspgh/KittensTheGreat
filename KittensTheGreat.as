package{
	import org.flixel.*;
	[SWF(width="640", height="480", backgroundcolor="#887090")]
	[Frame(factoryClass="Preloader")]

	public class KittensTheGreat extends FlxGame{
		public function KittensTheGreat(){
			super(320,240,GameState,2, 60, 60);
		}
	}
}

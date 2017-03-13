package cx.karoshi.controller
{	
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import cx.karoshi.IKaroshiApp;
	
	public class ViewContainer extends AbstractModuleController
	{
		public static const ID : String = '[[*]]';
		
		public function ViewContainer ()
		{
			super (new Sprite ());
			
			behaviours = - 1;
			
			setVisible (true, true);
			(interactiveObject as InteractiveObject).mouseEnabled = false;
		}
		
		override protected function onScreenDimension (screen : Rectangle) : void
		{
			
		}
	}
}
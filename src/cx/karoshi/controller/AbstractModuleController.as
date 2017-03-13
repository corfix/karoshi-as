package cx.karoshi.controller
{	
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
		
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import cx.karoshi.IKaroshiApp;
	
	public class AbstractModuleController extends EventDispatcher
	{
		private var _fx : DisplayObject;
		private var _visible : Boolean;
		private var _context : IKaroshiApp;
		
		protected var feed : XML;
		protected var behaviours : Number;
		protected var bounds : Rectangle;
		protected var screenSize : Rectangle;
		
		public function get visible () : Boolean { return _visible }
		public function get context () : IKaroshiApp { return _context }
		
		public function AbstractModuleController (obj : DisplayObject, behaviour : uint = 15)
		{
			if (Object (this).constructor === AbstractModuleController)
			{
				throw new ArgumentError ('Error #2012: AbstractController is an abstract class and cannot be instantiated.');
			}
			
			bounds = new Rectangle ();
			behaviours = behaviour;
			
			_fx = obj || new Sprite ();
			_fx.visible = false;
			
			_fx.addEventListener (Event.ADDED_TO_STAGE, _onInitialize, false, 7, true);
			_fx.addEventListener (Event.REMOVED_FROM_STAGE, _onFinalize, false, 7, true);
		}
		
		final public function get interactiveObject () : DisplayObject
		{
			return _fx;
		}
		
		final public function setContext (obj : IKaroshiApp) : void
		{
			if (_context)
			{
				throw new DefinitionError ('Context has already been set.');
			}
			
			_context = obj;
		}
		final public function setFeed (value : XML) : void
		{
			if (feed != value)
			{
				feed = value;
				_onInvalidate ();
			}
		}
		final public function setScreenDimension (screen : Rectangle, force : Boolean = false) : void
		{
			if (force || ! screenSize || ! screen.equals (screenSize))
			{
				screenSize = screen.clone ();
				onScreenDimension (screen);
			}
		}
		final public function setVisible (value : Boolean, immediate : Boolean = true) : void
		{
			if (interactiveObject is InteractiveObject) {
				(interactiveObject as InteractiveObject).mouseEnabled = value;
			}
			if (interactiveObject is DisplayObjectContainer) {
				(interactiveObject as DisplayObjectContainer).mouseChildren = value;
			}
			if (visible != value)
			{
				(_visible = value)
					? (! immediate 
						? onShow ()
						: onImmediateShow ())
					: (! immediate 
						? onHide ()
						: onImmediateHide ())
			}
		}
		
		protected function onScreenDimension (screen : Rectangle) : void
		{
			var box : Rectangle = bounds ? bounds : interactiveObject.getBounds (interactiveObject);
			
			interactiveObject.x = screen.x + box.x;
			interactiveObject.y = screen.y + box.y;
			
			if ((behaviours & ScreenPositionEnum.HORIZONTAL_CENTER) == ScreenPositionEnum.HORIZONTAL_CENTER)
			{
				interactiveObject.x += ((screen.width - box.width) / 2) | 0;
			}
			else if ((behaviours & ScreenPositionEnum.ALIGN_E) == ScreenPositionEnum.ALIGN_E)
			{
				interactiveObject.x += (screen.width - box.width) | 0;
			}
			else if ((behaviours & ScreenPositionEnum.ALIGN_W) == ScreenPositionEnum.ALIGN_W)
			{
				interactiveObject.x += (screen.x - box.x) | 0;
			}
			if ((behaviours & ScreenPositionEnum.VERTICAL_CENTER) == ScreenPositionEnum.VERTICAL_CENTER)
			{
				interactiveObject.y += ((screen.height - box.height) / 2) | 0;
			}
			else if ((behaviours & ScreenPositionEnum.ALIGN_N) == ScreenPositionEnum.ALIGN_N)
			{
				interactiveObject.y += (screen.y - box.y) | 0;
			}
			else if ((behaviours & ScreenPositionEnum.ALIGN_S) == ScreenPositionEnum.ALIGN_S)
			{
				interactiveObject.y += (screen.height - box.height - box.y) | 0;
			}
		}
		
		protected virtual function onHide () : void
		{
			onImmediateHide ();
		}
		protected virtual function onShow () : void
		{
			onImmediateShow ();
		}
		protected virtual function onImmediateHide () : void
		{
			interactiveObject.visible = false;
			callEvent ('onHide', 0);
		}
		protected virtual function onImmediateShow () : void
		{
			interactiveObject.visible = true;
			callEvent ('onShow', 0);
		}
		
		public function setHash (value : String) : void { }
		public function setPath (value : String) : void { }
		protected virtual function onInitialize () : void { }
		private function _onInitialize (e : Event) : void { onInitialize () }
		protected virtual function onFinalize () : void { }
		private function _onFinalize (e : Event) : void { onFinalize () }
		protected virtual function onInvalidate () : void { }
		private function _onInvalidate () : void { onInvalidate () }
		
		final protected function callEvent (v : String, ms : uint = 0) : void
		{
			import flash.utils.setTimeout
			
			setTimeout (dispatchEvent, ms, new Event (v));
		}
	}
}
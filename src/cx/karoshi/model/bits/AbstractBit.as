package cx.karoshi.model.bits
{
	/**
	 * ...
	 * @author Mikolaj Musielak
	 */
	
	import cx.karoshi.controller.AbstractModuleController;
	import flash.display.DisplayObject;
	
	internal class AbstractBit
	{
		private var bitClass : Class;
		private var bitID : String;
		private var bitInstance : AbstractModuleController;
		
		public function AbstractBit (ID : String, lClass : Class)
		{
			if (Object (this).constructor === AbstractBit)
			{
				throw new ArgumentError ('Error #2012: AbstractBit is an abstract class and cannot be instantiated.');
			}
			
			bitID = ID;
			bitClass = lClass;
			
			bitInstance = new bitClass ();
				
			if (! (bitInstance is AbstractModuleController))
			{
				throw new ArgumentError ('Invalid argument. Supplied class should extends cx.karoshi.controller.AbstractController.');
			}
		}
		
		public function get ID () : String
		{
			return bitID;
		}
		public function get instanceController () : AbstractModuleController
		{
			if (! bitInstance)
			{
				bitInstance = new bitClass ();
			}
			
			return bitInstance;
		}
		public function get instanceView () : DisplayObject
		{
			return instanceController.interactiveObject;
		}
	}
}
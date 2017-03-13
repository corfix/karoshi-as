package cx.karoshi.model.bits
{
	/**
	 * ...
	 * @author Mikolaj Musielak
	 */
	
	import cx.karoshi.controller.ScreenBehaviourEnum;
	
	public class ModuleBit extends AbstractBit
	{
		protected var bitFeed : XML;
		protected var scrOrder : Number;
		protected var scrBehaviour : Number;
		
		public function ModuleBit (ID : String, lClass : Class, lFeed : XML, lBehaviour : Number = 0, lOrder : Number = 1)
		{
			super (ID, lClass);
			
			bitFeed = lFeed;
			scrBehaviour = lBehaviour;
			scrOrder = lOrder;
		}
		
		public function get screenBehaviour () : Number
		{
			return scrBehaviour;
		}
		public function get screenOrder () : Number
		{
			return scrOrder;
		}
	}
}
package cx.karoshi.model.bits
{
	/**
	 * ...
	 * @author Mikolaj Musielak
	 */
	
	
	public class LocationBit extends AbstractBit
	{
		private var bitFeed : XML;
		
		public function LocationBit (ID : String, lClass : Class, lFeed : XML)
		{
			super (ID, lClass);
			
			bitFeed = lFeed;
		}
		
		public function get feed () : XML
		{
			return bitFeed;
		}
	}
}
package cx.karoshi.model.bits
{
	/**
	 * ...
	 * @author Mikolaj Musielak
	 */
	
	
	public class SectionBit
	{
		protected var bitID : String;
		protected var bitFeed : XMLList; // TODO: change it ASAP!
		
		public function SectionBit (ID : String, lFeed : XMLList)
		{
			bitID = ID;
			bitFeed = lFeed;
		}
		
		public function get ID () : String
		{
			return bitID;
		}
		
		public function get modulesFeed () : XMLList
		{
			return bitFeed;
		}
	}
}
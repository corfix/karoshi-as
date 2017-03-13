package cx.karoshi.nav
{
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.events.Event;
	
	public class SiteNavEvent extends Event
	{
		public static const EXTERNAL_CHANGE : String = 'EXTERNAL_CHANGE';
		public static const INTERNAL_CHANGE : String = 'INTERNAL_CHANGE';
		
		public function SiteNavEvent (k : String)
		{
			super (k)
		}
	}
}
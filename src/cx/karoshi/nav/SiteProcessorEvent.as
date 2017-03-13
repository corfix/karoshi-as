package cx.karoshi.nav
{	
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.events.Event;
	
	public class SiteProcessorEvent extends Event
	{
		public static const ASK_INVALIDATE : String = 'ASK_INVALIDATE';
		public static const TRANSITION_START : String = 'TRANSITION_START';
		public static const TRANSITION_PHASE : String = 'TRANSITION_PHASE';
		public static const TRANSITION_COMPLETE : String = 'TRANSITION_COMPLETE';
		
		public function SiteProcessorEvent (type : String)
		{
			super (type);
		}
	}
}
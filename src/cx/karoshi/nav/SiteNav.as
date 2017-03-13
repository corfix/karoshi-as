package cx.karoshi.nav
{
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	public class SiteNav extends EventDispatcher
	{
		protected var locHash : String;
		protected var locPath : String;
		
		public function SiteNav ()
		{
			locHash = '';
			locPath = '/';
		}
		public function initialize () : void
		{
			dispatchEvent (new SiteNavEvent (SiteNavEvent.INTERNAL_CHANGE));
		}
		public function get locationHash () : String
		{
			return locHash;
		}
		public function set locationHash (value : String) : void
		{
			locHash = value;
			dispatchEvent (new SiteNavEvent (SiteNavEvent.INTERNAL_CHANGE));
		}
		public function get locationPath () : String
		{
			return locPath;
		}
		public function set locationPath (value : String) : void
		{
			if (! value.match (/^\//)) value = '/' + value;
			if (! value.match (/\/$/)) value = value + '/';
			
			locPath = value;
			
			dispatchEvent (new SiteNavEvent (SiteNavEvent.INTERNAL_CHANGE));
		}
	}
}
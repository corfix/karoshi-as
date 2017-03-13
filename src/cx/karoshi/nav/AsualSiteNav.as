package cx.karoshi.nav
{	
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	
	[ExcludeClass]
	public class AsualSiteNav extends SiteNav
	{
		public function AsualSiteNav ()
		{
			locHash = null;
			locPath = null;
			
			SWFAddress.addEventListener (SWFAddressEvent.EXTERNAL_CHANGE, onExtLocationChange, false, 9, true);
			SWFAddress.addEventListener (SWFAddressEvent.INTERNAL_CHANGE, onIntLocationChange, false, 9, true);
		}
		override public function initialize () : void
		{
		//	dispatchEvent (new SiteNavEvent (SiteNavEvent.INTERNAL_CHANGE));
		}
		override public function get locationHash () : String
		{
			return SWFAddress.getQueryString ();
		}
		override public function set locationHash (value : String) : void
		{
			SWFAddress.setValue (SWFAddress.getPath () + (value == '' ? '' : '?' + value));
		}
		override public function get locationPath () : String
		{
			var value : String = SWFAddress.getPath ();
			
			if (! value.match (/^\//)) value = '/' + value;
			if (! value.match (/\/$/)) value = value + '/';
			
			return value;
		}
		override public function set locationPath (value : String) : void
		{
			if (! value.match (/^\//)) value = '/' + value;
			if (! value.match (/\/$/)) value = value + '/';
			
			SWFAddress.setValue (value);
		}
		
		protected function onExtLocationChange (e : Event) : void
		{
			trace ('\t* NOTICE', 'AsualSiteNav.ExternalAddressChange');
			
			dispatchEvent (new SiteNavEvent (SiteNavEvent.EXTERNAL_CHANGE));
		}
		protected function onIntLocationChange (e : Event) : void
		{
			trace ('\t* NOTICE', 'AsualSiteNav.InternalAddressChange');
			
			dispatchEvent (new SiteNavEvent (SiteNavEvent.INTERNAL_CHANGE));
		}
	}
}
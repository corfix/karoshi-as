package cx.karoshi.model.source
{	
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.events.Event;
	
	import cx.karoshi.controller.ViewContainer;
	import cx.karoshi.model.SiteModel;
	import cx.karoshi.model.bits.LocationBit;
	import cx.karoshi.model.bits.ModuleBit;
	import cx.karoshi.model.bits.SectionBit;
	
	public class UserDataSource extends DataSource
	{
		public function UserDataSource (defaultPath : String = '/')
		{
			super (defaultPath);
			
			model.addModule (new ModuleBit (ViewContainer.ID, ViewContainer, null, 0));
		}
		
		public function addLocation (ID : String, lClass : Class, lFeed : XML = null) : uint
		{
			return model.addLocation (new LocationBit (ID, lClass, lFeed));
		}
		public function addModule (ID : String, lClass : Class, lFeed : XML = null, lBehaviour : Number = 0, zSort : Number = - 1) : uint
		{
			return model.addModule (new ModuleBit (ID, lClass, lFeed, lBehaviour, zSort));
		}
		public function addSection (ID : String, lFeed : XMLList) : uint
		{
			return model.addSection (new SectionBit (ID, lFeed));
		}
		
		override public function fetch () : void
		{
			dispatchEvent (new Event (Event.COMPLETE));
		}
	}
}
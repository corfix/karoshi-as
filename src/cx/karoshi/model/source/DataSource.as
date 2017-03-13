package cx.karoshi.model.source
{	
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.events.EventDispatcher;
	
	import cx.karoshi.model.SiteModel;
	import cx.karoshi.model.bits.LocationBit;
	import cx.karoshi.model.bits.ModuleBit;
	import cx.karoshi.model.bits.SectionBit;
	import cx.karoshi.IKaroshiApp;
	
	public class DataSource extends EventDispatcher implements IDataSource
	{
		protected var model : SiteModel;
		
		public function DataSource (defaultPath : String = '/')
		{
			if (Object (this).constructor === DataSource)
			{
				throw new ArgumentError ('Error #2012: DataSource is an abstract class and cannot be instantiated.');
			}
			
			model = new SiteModel (defaultPath);
		}
		
		final public function get definition () : SiteModel
		{
			return model;
		}
		
		public virtual function fetch () : void
		{
			
		}
	}
}
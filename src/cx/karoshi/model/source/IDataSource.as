package cx.karoshi.model.source
{
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import cx.karoshi.IKaroshiApp;
	import flash.events.IEventDispatcher;
	import cx.karoshi.model.SiteModel;
	
	public interface IDataSource extends IEventDispatcher
	{
		function fetch () : void
		
		function get definition () : SiteModel
	}
}
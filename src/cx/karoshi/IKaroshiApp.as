package cx.karoshi
{
	import cx.karoshi.model.bits.ModuleBit;
	import cx.karoshi.model.bits.SectionBit;
	import cx.karoshi.model.bits.LocationBit;
	
	public interface IKaroshiApp
	{
		function get siteURL () : String
		function get locationHash () : String
		function set locationHash (value : String) : void
		function get locationPath () : String
		function set locationPath (value : String) : void
		
		function findModule (label : String) : ModuleBit
		function findLocation (label : String) : LocationBit
	}
}
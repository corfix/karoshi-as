package cx.karoshi.nav
{	
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import cx.karoshi.model.bits.LocationBit;
	import cx.karoshi.model.bits.SectionBit;
	
	internal class SiteProcessorCmd
	{
		public function SiteProcessorCmd (immediate : Boolean)
		{
			immediateChanges = immediate;
		}
		
		public var immediateChanges : Boolean;
		public var currentSection : SectionBit;
		public var currentLocation : LocationBit;
		public var candidateSection : SectionBit;
		public var candidateLocation : LocationBit;
	}
}
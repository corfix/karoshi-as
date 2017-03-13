package cx.karoshi.model
{
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import cx.karoshi.model.bits.LocationBit;
	import cx.karoshi.model.bits.ModuleBit;
	import cx.karoshi.model.bits.SectionBit;
	
	public class SiteModel
	{
		public var defaultPath : String;
		
		private const siteLocations : Vector.<LocationBit> = new Vector.<LocationBit>;
		private const siteModules : Vector.<ModuleBit> = new Vector.<ModuleBit>;
		private const siteSections : Vector.<SectionBit> = new Vector.<SectionBit>;
		
		public function get iterateLocations () : Vector.<LocationBit> {
			return siteLocations;
		}
		public function get iterateModules () : Vector.<ModuleBit> {
			return siteModules;
		}
		public function get iterateSections () : Vector.<SectionBit> {
			return siteSections;
		}
		
		public function SiteModel (defaultPath : String = '/')
		{
			this.defaultPath = defaultPath;
		}
		
		public function addLocation (bit : LocationBit) : uint
		{
			var i : uint = siteLocations.length;
			
			siteLocations [i] = bit;
			
			return i;
		}
		public function getLocation (bitID : String) : LocationBit
		{
			var o : LocationBit;
			
			for each (var bit : LocationBit in siteLocations)
			{
				if (bit.ID == bitID)
				{
					o = bit; break;
				}
			}
			
			return o;
		}
		public function addModule (bit : ModuleBit) : uint
		{
			siteModules.push (bit);
			
			siteModules.sort
			(
				function (a : ModuleBit, b : ModuleBit) : Number
				{
					if (a.screenOrder > b.screenOrder) return + 1;
					if (a.screenOrder < b.screenOrder) return - 1;
					
					return 0;
				}
			)
			
			return siteModules.length;
		}
		public function getModule (bitID : String) : ModuleBit
		{
			var o : ModuleBit;
			
			for each (var bit : ModuleBit in siteModules)
			{
				if (bit.ID == bitID)
				{
					o = bit; break;
				}
			}
			
			return o;
		}
		public function addSection (bit : SectionBit) : uint
		{
			var i : uint = siteSections.length;
			
			siteSections [i] = bit;
			
			return i;
		}
		public function getSection (bitID : String) : SectionBit
		{
			var o : SectionBit;
			
			for each (var bit : SectionBit in siteSections)
			{
				if (bit.ID == bitID)
				{
					o = bit; break;
				}
			}
			
			return o;
		}
		
		public function matchSection (locationPath : String) : SectionBit
		{
			if (! locationPath.match (/^\//)) locationPath = '/' + locationPath;
			if (! locationPath.match (/\/$/)) locationPath = locationPath + '/';
			
			var stack : Array = [null];
			
			for each (var section : SectionBit in siteSections)
			{
				var sectionPath : String = section.ID;
				
				if (! locationPath.indexOf (sectionPath))
				{
					if (locationPath == sectionPath)
					{
						stack.unshift ({v: section, k: - 1});
					}
					else
					{
						stack.unshift ({v: section, k: sectionPath.match ('^(.*?\/)').length });
					}
				}
				else if (sectionPath.indexOf ('*') > 0)
				{
					var joker : String = sectionPath.toString ().replace (/\*\/$/gx, '');
					
					if (! locationPath.indexOf (joker) && locationPath != joker)
					{
						stack.unshift ({v: section, k: sectionPath.match ('^(.*?\/)').length});
					}
				}
			}
			
			stack.sortOn ('k', Array.NUMERIC);
			return stack.length > 1 ? stack [0].v : null;
		}
	}
}
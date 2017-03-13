package cx.karoshi.model.source
{
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.system.ApplicationDomain;
	
	import cx.karoshi.controller.ScreenBehaviourEnum;
	import cx.karoshi.controller.ScreenPositionEnum;
	import cx.karoshi.controller.ViewContainer;
	import cx.karoshi.model.bits.LocationBit;
	import cx.karoshi.model.bits.ModuleBit;
	import cx.karoshi.model.bits.SectionBit;
	
	import cx.karoshi.model.SiteModel;
	
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.XMLLoader;
	
	[ExcludeClass]
	public class XmlDataSource extends DataSource
	{
		private var ldr : LoaderMax;
		
		private static const LOADER_GROUP_INI : String = '[INI]';
		private static const LOADER_GROUP_SWC : String = '[SWC]';
		private static const LOADER_GROUP_XML : String = '[XML]';
		
		
		public function XmlDataSource (xmlPath : String, defaultPath : String = '/')
		{
			super (defaultPath);
			
			ldr = new LoaderMax ();
			ldr.addEventListener (LoaderEvent.PROGRESS, onProgress);
			ldr.addEventListener (LoaderEvent.CHILD_FAIL, onAssetFailure);
			ldr.addEventListener (LoaderEvent.CHILD_COMPLETE, onAssetSuccess);
			
			ldr.append (new XMLLoader (xmlPath, { name: LOADER_GROUP_INI } ));
		}
		
		override public function fetch () : void
		{
			ldr.load ();
		}
		
		protected function loadSWC () : void
		{
			var o : LoaderMax = new LoaderMax ({ name: LOADER_GROUP_SWC });
			
			for each (var filePath : String in ldr.getContent (LOADER_GROUP_INI).ClassPath.@File)
			{
				if (filePath != '')
				{
					o.append (new DataLoader (filePath, { name: filePath } ));
				}
			}
			
			ldr.append (o).load ();
		}
		protected function loadXML () : void
		{
			var o : LoaderMax = new LoaderMax ({ name: LOADER_GROUP_XML });
			
			for each (var filePath : String in ldr.getContent (LOADER_GROUP_INI)..@ContentFeed)
			{
				if (filePath != '')
				{
					o.append (new DataLoader (filePath, { name: filePath } ));
				}
			}
			
			ldr.append (o).load ();
		}
		
		protected function parseXML () : void
		{
			model.defaultPath = ldr.getContent (LOADER_GROUP_INI).SiteVariables.DefaultPath.@Value;
			
			parseModules ();
			parseSections ();
			parseLocations ();
			
			trace ('\t* DEBUG', 'Parse FINISHED');
			
			dispatchEvent (new Event (Event.COMPLETE));
		}
		
		protected function parseModules () : void
		{
			var sortData : Array = [ <Module RefID="-*-" ZSort="0" /> ];
			
			var z : Number = 999;
			
			for each (var Node : XML in ldr.getContent (LOADER_GROUP_INI).Modules.Module)
			{
				if (isNaN (parseInt (Node.@ZSort)))
				{
					Node.@ZSort = -- z;
					
					trace ('\t* WARNING', 'Module >' + Node.@RefID + '< has incorrect ZSort value.');
				}
				else
				{
					z = parseInt (Node.@ZSort);
				}
				
				sortData.unshift (Node);
			}
			
			sortData.sortOn ('@ZSort', 16);
			
			for each (var sortItem : XML in sortData)
			{
				var feedXML : XML;
				
				if (sortItem.@ContentFeed.toString () != '')
				{
					feedXML = XML (ldr.getContent (sortItem.@ContentFeed));
				}
				else if (sortItem.Data.ContentFeed.toXMLString () != '')
				{
					feedXML = sortItem.ContentFeed [0];
				}
				
				if (sortItem.@RefID == '-*-')
				{
					model.addModule (new ModuleBit (ViewContainer.ID, ViewContainer, null, - 1));
				}
				else if (ApplicationDomain.currentDomain.hasDefinition (sortItem.@Class))
				{
					var l : Number = ScreenBehaviourEnum.DEFAULT;
					
					if (sortItem.@Layout.toUpperCase () == 'GREED')
					{
						l = ScreenBehaviourEnum.GREED;
					}
					if (sortItem.@Layout.toUpperCase () == 'MODAL')
					{
						l = ScreenBehaviourEnum.MODAL;
					}
					
					model.addModule (new ModuleBit (sortItem.@RefID, ApplicationDomain.currentDomain.getDefinition (sortItem.@Class) as Class, feedXML, l));
				}
				else
				{
					trace ('\t* CRITICAL', 'Module ' + sortItem.@RefID + ' relies on definition of ' + sortItem.@Class + ' which could not be found!');
				}
			}
		}
		protected function parseSections () : void
		{
			var sortData : Array = [];
			
			for each (var Node : XML in ldr.getContent (LOADER_GROUP_INI).Sections.Section)
			{
				// Never trust your users!
				if (! Node.@Path.match (/^\//)) Node.@Path = '/' + Node.@Path;
				if (! Node.@Path.match (/\/$/)) Node.@Path = Node.@Path + '/';
				
				sortData.unshift (Node);
			}
			
			sortData.sortOn ('@Path', 4);
			
			// TODO: FIX
			
			for each (var sortItem : XML in sortData)
			{
				var ancestors : Array = sortItem.@Path.match (/([^\/]+)?\//gx);
				
				for (var i : uint = ancestors.length - 1; i > 0; i --)
				{
					var ancestor : XMLList = ldr.getContent (LOADER_GROUP_INI).Sections.Section.(@Path == ancestors.slice (0, i).join (''));
					
					for each (var ModConfNode : XML in ancestor.Module)
					{
						var ConfNodeExists : Boolean = Boolean (0);
						
						for each (var ChildModConfNode : XML in sortItem.Module)
						{
							if (ChildModConfNode.@RefID == ModConfNode.@RefID)
							{
								ConfNodeExists = Boolean (1); break;
							}
						}
						if (! ConfNodeExists)
						{
							sortItem.appendChild (ModConfNode);
						}
					}
				}
				
				var sectionBean : SectionBit = new SectionBit (sortItem.@Path, XMLList (sortItem));
				
				model.addSection (sectionBean);
			}
		}
		protected function parseLocations () : void
		{
			for each (var obj : XML in ldr.getContent (LOADER_GROUP_INI).Locations.Location)
			{
				var feedXML : XML;
				
				if (obj.@ContentFeed.toString () != '')
				{
					feedXML = XML (ldr.getContent (obj.@ContentFeed));
				}
				else if (obj.ContentFeed.toXMLString () != '')
				{
					feedXML = obj.ContentFeed [0];
				}
				
				if (ApplicationDomain.currentDomain.hasDefinition (obj.@Class))
				{
					model.addLocation (new LocationBit (obj.@Path, ApplicationDomain.currentDomain.getDefinition (obj.@Class) as Class, feedXML, obj.@Name));
				}
				else
				{
					trace ('\t* CRITICAL', 'Location ' + obj.@Path + ' relies on definition of ' + obj.@Class + ' which could not be found!');
				}
			}
		}
		
		protected function onProgress (e : LoaderEvent) : void
		{
			dispatchEvent (new ProgressEvent (ProgressEvent.PROGRESS, false, false, e.target.bytesLoaded, e.target.bytesTotal));
		}
		protected function onAssetSuccess (e : LoaderEvent) : void
		{
			switch (e.target.name)
			{
				case LOADER_GROUP_INI:
					loadSWC (); break;
					
				case LOADER_GROUP_SWC:
					loadXML (); break;
					
				case LOADER_GROUP_XML:
					parseXML (); break;
			}
		}
		protected function onAssetFailure (e : LoaderEvent) : void
		{
			trace ('\t* WARNING', 'File ' + e.target.name + ' could not be found!');
		}
	}
}
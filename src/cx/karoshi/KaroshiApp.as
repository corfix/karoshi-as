package cx.karoshi
{
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import cx.karoshi.controller.ScreenBehaviourEnum;
	import cx.karoshi.controller.ScreenPositionEnum;
	import cx.karoshi.controller.ViewContainer;
	import cx.karoshi.model.bits.ModuleBit;
	import cx.karoshi.model.bits.LocationBit;
	import cx.karoshi.model.source.IDataSource;
	import cx.karoshi.model.SiteModel;
	import cx.karoshi.nav.SiteNav;
	import cx.karoshi.nav.SiteNavEvent;
	import cx.karoshi.nav.SiteProcessor;
	import cx.karoshi.nav.SiteProcessorEvent;
	
	public class KaroshiApp implements IKaroshiApp
	{
		protected var host : Sprite;
		protected var dataSource : IDataSource;
		//
		protected var model : SiteModel;
		protected var nav : SiteNav;
		protected var processor : SiteProcessor;
		//
		protected var currentPath : String;
		
		public function KaroshiApp (host : Sprite, siteNav : SiteNav = null)
		{
			this.host = host;
			
			nav = siteNav || new SiteNav ();
			processor = new SiteProcessor ();
		}
		
		public function setDataSource (obj : IDataSource) : void
		{
			if (! dataSource)
			{
				dataSource = obj;
				dataSource.addEventListener (Event.COMPLETE, onDataSource);
				dataSource.fetch ();
			}
			else throw new IllegalOperationError ('DataSource has been already definied!');
		}
		
		protected function onDataSource (e : Event) : void
		{
			model = dataSource.definition;
			
			processor.setSiteModel (model);
			
			var hasSections : Boolean = model.iterateSections.length > 0;
			
			for each (var module : ModuleBit in model.iterateModules)
			{
				module.instanceController.setContext (this);
				host.addChild (module.instanceView);
				
				if (! hasSections) {
					module.instanceController.setVisible (true, false);
				}
			}
			
			host.stage.addEventListener (Event.RESIZE, onEnvironmentChange);
			
			dataSource.removeEventListener (Event.COMPLETE, onDataSource);
			
			nav.addEventListener (SiteNavEvent.EXTERNAL_CHANGE, onLocationExtChange);
			nav.addEventListener (SiteNavEvent.INTERNAL_CHANGE, onLocationIntChange);
			
			processor.addEventListener (SiteProcessorEvent.ASK_INVALIDATE, onEnvironmentChange);
			processor.addEventListener (SiteProcessorEvent.TRANSITION_PHASE, onEnvironmentChange);
			processor.addEventListener (SiteProcessorEvent.TRANSITION_START, onTransitionStart);
			processor.addEventListener (SiteProcessorEvent.TRANSITION_COMPLETE, onTransitionComplete);
			
			nav.initialize ();
		}
		protected function onInvalidate (force : Boolean = false) : void
		{
			var bit : ModuleBit;
			
			var screenSize : Rectangle = new Rectangle (0, 0, host.stage.stageWidth, host.stage.stageHeight);
			
			for each (bit in model.iterateModules)
			{
				if ((bit.screenBehaviour == ScreenBehaviourEnum.MODAL) && bit.instanceController.visible) {
					bit.instanceController.setScreenDimension (screenSize.clone (), force);
				}
			}
			for each (bit in model.iterateModules)
			{
				if ((bit.screenBehaviour == ScreenBehaviourEnum.GREED) && bit.instanceController.visible) {
					bit.instanceController.setScreenDimension (screenSize, force);
				}
			}
			for each (bit in model.iterateModules)
			{
				if ((bit.screenBehaviour == ScreenBehaviourEnum.DEFAULT) && bit.instanceController.visible) {
					bit.instanceController.setScreenDimension (screenSize.clone (), force);
				}
			}
			
			model.getLocation (locationPath).instanceController.setScreenDimension (screenSize, force);
		}
		protected function invalidateLocation (immediate : Boolean = false) : void
		{
			var reqPath : String = nav.locationPath;
			var reqHash : String = nav.locationHash;
			
			if (currentPath == reqPath)
			{ 
				for each (var bit : ModuleBit in model.iterateModules)
				{
					bit.instanceController.setHash (reqHash);
				}
				
				model.getLocation (locationPath).instanceController.setHash (reqHash);
			}
			else
			{
				if (! model.getLocation (reqPath))
				{
					throw new Error ('FatalError: Location 404 ' + reqPath, 404);
				}
				else
				{
					model.getLocation (reqPath).instanceController.setContext (this);
					(model.getModule (ViewContainer.ID).instanceView as DisplayObjectContainer).addChild (model.getLocation (reqPath).instanceView);
				}
				
				processor.start (model.getLocation (currentPath), model.getLocation (reqPath), immediate);
			}
		}
		
		// --- locationMediator
		
		public function get siteURL () : String
		{
			return host.stage.loaderInfo.url;
		}
		public function get locationHash () : String
		{
			return nav.locationHash;
		}
		public function set locationHash (value : String) : void
		{
			nav.locationHash = value;
		}
		public function get locationPath () : String
		{
			return nav.locationPath;
		}
		public function set locationPath (value : String) : void
		{
			nav.locationPath = value;
		}
		
		public function findModule (label : String) : ModuleBit
		{
			return model.getModule (label);
		}
		public function findLocation (label : String) : LocationBit
		{
			return model.getLocation (label);
		}
		
		// --- 
		
		protected function onEnvironmentChange (e : Event) : void
		{
			onInvalidate ();
		}
		protected function onLocationExtChange (e : Event) : void
		{
			trace ('\t* NOTICE', 'Site.ExternalAddressChange');
			
			invalidateLocation (! currentPath ? false : true);
		}
		protected function onLocationIntChange (e : Event) : void
		{
			trace ('\t* NOTICE', 'Site.InternalAddressChange'); 
			
			invalidateLocation ();
		}
		protected function onTransitionStart (e : Event) : void
		{
			host.mouseEnabled = false;
			host.mouseChildren = false;
			
			for each (var bit : ModuleBit in model.iterateModules)
			{
				bit.instanceController.setPath (processor.candidateLocation.ID);
			}
			
			model.getLocation (locationPath).instanceController.setPath (processor.candidateLocation.ID);
		}
		protected function onTransitionComplete (e : Event) : void
		{
			host.mouseEnabled = true;
			host.mouseChildren = true;
			
			onInvalidate (true);
			currentPath = locationPath;
			model.getLocation (locationPath).instanceController.setHash (locationHash);
		}
	}
}
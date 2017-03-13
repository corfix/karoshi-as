package cx.karoshi.nav
{
	/**
	 * ...
	 * @author Mikołaj Musielak
	 */
	
	import cx.karoshi.controller.AbstractModuleController;
	import cx.karoshi.model.bits.LocationBit;
	import cx.karoshi.model.bits.SectionBit;
	import cx.karoshi.model.SiteModel;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class SiteProcessor extends EventDispatcher
	{
		private var state : uint;
		private var tasks : uint;
		private var cmd : SiteProcessorCmd;
		private var queue : Array;
	
		protected var model : SiteModel;
		
		
		public function SiteProcessor ()
		{
			state = 0;
			tasks = 0;
			
			queue = [];
		}
		
		public function get currentLocation () : LocationBit
		{
			return cmd.currentLocation;
		}
		public function get currentSection () : SectionBit
		{
			return cmd.currentSection;
		}
		public function get candidateLocation () : LocationBit
		{
			return cmd.candidateLocation;
		}
		public function get candidateSection () : SectionBit
		{
			return cmd.candidateSection;
		}
		
		public function setSiteModel (obj : SiteModel) : void
		{
			model = obj;
		}
		
		public function start (pvLoc : LocationBit, nxLoc : LocationBit, immediate : Boolean) : void
		{
			if (! model)
			{
				throw new UninitializedError ('SiteModel is missing!');
			}
			
			var o : SiteProcessorCmd = new SiteProcessorCmd (immediate);
			
			if (pvLoc)
			{
				o.currentSection = model.matchSection (pvLoc.ID);
				o.currentLocation = pvLoc;
			}
			if (nxLoc)
			{
				o.candidateSection = model.matchSection (nxLoc.ID);
				o.candidateLocation = nxLoc;
			}
			if (o.candidateSection == o.currentSection)
			{
				o.currentSection = null;
				o.candidateSection = null;
			}
			
			queue.push (o);
			processQueue ();
		}
		
		public function idle () : Boolean
		{
			return Boolean (cmd);
		}
		
		protected function processQueue () : void
		{
			if (state == 0)
			{
				cmd = queue.shift ();
				
				dispatchEvent (new SiteProcessorEvent (SiteProcessorEvent.TRANSITION_START));
				
				processTransition ();
			}
		}
		protected function processTransition () : void
		{
			if (cmd && tasks <= 0)
			{
				state ++;
				tasks = 0;
				
				dispatchEvent (new SiteProcessorEvent (SiteProcessorEvent.TRANSITION_PHASE));
				
				if (state == 0)
				{
					//
				}
				else if (state == 1 && cmd.currentLocation) // HIDE PV LOCATION
				{
					setModuleState (cmd.currentLocation.instanceController, false, cmd.immediateChanges);
				}
				else if (state == 2 && cmd.currentSection) // HIDE PV SECTION
				{
					//
				}
				else if (state == 3 && cmd.candidateSection) // SHOW NX SECTION
				{
					for each (var node : XML in cmd.candidateSection.modulesFeed..Module)
					{
						if (node.@RefID.toString () == '' || node.@Visible.toString () == '')
						{
							trace ('\t* WARNING', 'MALFORMATED XML NODE', node.toXMLString ()); continue;
						}
						else if (! model.getModule (node.@RefID))
						{
							trace  ('\t* WARNING', 'COULD NOT FIND MODULE DEFINITION', node.toXMLString ()); continue;
						}
						
						if (node.ContentFeed.toXMLString () != '')
						{
							model.getModule (node.@RefID).instanceController.setFeed (XML (node.ContentFeed));
						}
						
						setModuleState (model.getModule (node.@RefID).instanceController, node.@Visible.toUpperCase () == 'TRUE', cmd.immediateChanges);
					}
				}
				else if (state == 4 && cmd.candidateLocation) // SHOW NX LOCATION
				{
					if (cmd.currentLocation)
					{
						cmd.currentLocation.instanceView.parent.removeChild (cmd.currentLocation.instanceView);
					}
					
					cmd.candidateLocation.instanceController.setFeed (cmd.candidateLocation.feed);
					setModuleState (cmd.candidateLocation.instanceController, true, cmd.immediateChanges);
				}
				else if (state == 5)
				{
					state = 0;
					tasks = 0;
					
					cmd = null;
					
					dispatchEvent (new SiteProcessorEvent (SiteProcessorEvent.TRANSITION_COMPLETE));
					
					if (queue.length > 0)
					{
						processQueue (); return;
					}
				}
				
				dispatchEvent (new SiteProcessorEvent (SiteProcessorEvent.ASK_INVALIDATE));
				
				processTransition ();
			}
		}
		
		protected function setModuleState (instance : AbstractModuleController, visible : Boolean, immediate : Boolean) : void
		{
			if (visible && ! instance.visible)
			{
				tasks ++;
				
				instance.addEventListener ('onHide', onHideSuccess);
				instance.addEventListener ('onShow', onShowSuccess);
				
				instance.setVisible (true, immediate);
			}
			else if (! visible && instance.visible)
			{
				tasks ++;
				
				instance.addEventListener ('onHide', onHideSuccess);
				instance.addEventListener ('onShow', onShowSuccess);
				
				instance.setVisible (false, immediate);
			}
		}
		
		protected function onHideSuccess (e : Event) : void
		{
			tasks --;
			
			e.target.removeEventListener ('onHide', onHideSuccess);
			
			processTransition ();
		}
		protected function onShowSuccess (e : Event) : void
		{
			tasks --;
			
			e.target.removeEventListener ('onShow', onShowSuccess);
			
			processTransition ();
		}
	}
}

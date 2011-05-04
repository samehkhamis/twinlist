package twinlist
{
	import flash.events.Event;
	
	public class TwinListEvent extends Event
	{
		private var data:Object;
		
		public function TwinListEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			Data = data;
		}

		public function get Data():Object
		{
			return data;
		}
		public function set Data(value:Object):void
		{
			data = value;
		}
	}
}
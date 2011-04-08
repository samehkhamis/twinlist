package twinlist
{
	import spark.components.Application;
	import flash.display.Sprite;
	import flare.display.TextSprite;
	import flare.flex.vis.FlareCanvas;
	import mx.events.FlexEvent;
	
	public class TwinListClass extends Application
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function TwinListClass()
		{
			super();
		}
	}
}
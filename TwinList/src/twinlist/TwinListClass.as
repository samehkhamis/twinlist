package twinlist
{
	import spark.components.Application;
	
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
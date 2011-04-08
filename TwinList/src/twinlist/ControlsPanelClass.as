package twinlist
{
	import spark.components.Group;
	
	public class ControlsPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function ControlsPanelClass()
		{
			super();
		}
	}
}
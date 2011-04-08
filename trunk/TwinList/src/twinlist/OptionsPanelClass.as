package twinlist
{
	import spark.components.Group;
	
	public class OptionsPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function OptionsPanelClass()
		{
			super();
		}
	}
}
package twinlist
{
	import spark.components.Group;
	
	public class FilterPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function FilterPanelClass()
		{
			super();
		}
	}
}
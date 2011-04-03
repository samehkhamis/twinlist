package twinlist
{
	import spark.components.Group;
	
	public class ActionListClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function ActionListClass()
		{
			super();
		}
	}
}
package twinlist {
	
	import spark.components.Group;

	public class FilterPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function FilterPanelClass()
		{
			super();
		}
		
		protected function OnButtonDown(text:String):void {
			// Triggers a filtering op in the list view based on string in "text"
			model.FilterByString = text;
		}
	}
}
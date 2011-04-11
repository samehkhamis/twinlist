package twinlist
{
	import com.carlcalderon.arthropod.Debug;
	
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.events.IndexChangeEvent;
	
	public class ControlsPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
		public function ControlsPanelClass()
		{
			super();
		}
		
		protected function OnChange(event:IndexChangeEvent):void {

			// Based on selected control will set the SortBy, GroupBy or ... of the model and refresh the list view.
			var dd:DropDownList=event.target as DropDownList;
			switch (dd.id) {
				case "SortByList":
					model.SortBy=model.ListItemAttributes.getItemAt(event.newIndex).toString();
					Debug.log("SortByList");
					break;
				case "GroupByList":
					Debug.log("GroupByList");
					model.GroupBy=model.ListItemAttributes.getItemAt(event.newIndex).toString();
					break;
				/*
				case "ColorByList":
					Debug.log("ColorByList");
					model.ColorBy=model.ListItemAttributes.getItemAt(event.newIndex).toString();
					break;
				*/
			}
				
		}
			
	}
}
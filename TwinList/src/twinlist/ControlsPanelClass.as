package twinlist
{
	import com.carlcalderon.arthropod.Debug;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
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
			var dd:DropDownList = event.target as DropDownList;
			switch (dd.id) {
				case "SizeByList":
					//Debug.log("ColorByList");
					model.SizeBy = model.NumericalAttributes[event.newIndex];
					break;
				case "ColorByList":
					//Debug.log("ColorByList");
					model.ColorBy = model.CategoricalAttributes[event.newIndex];
					break;
				case "groupByList":
					//Debug.log("GroupByList");
					model.GroupBy = model.CategoricalAttributes[event.newIndex];
					break;
				case "sortByList":
					//Debug.log("SortByList");
					model.SortBy = model.DataAttributes[event.newIndex];
					break;
			}
		}
	}
}
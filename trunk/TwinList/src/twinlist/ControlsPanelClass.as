package twinlist
{
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
		[Bindable]
		protected var categoricalOptions:ArrayCollection;
		[Bindable]
		protected var numericalOptions:ArrayCollection;
		[Bindable]
		protected var generalOptions:ArrayCollection;
		
		public function ControlsPanelClass()
		{
			super();
			categoricalOptions = CreateOptionsList(model.CategoricalAttributes);
			numericalOptions = CreateOptionsList(model.NumericalAttributes);
			generalOptions = CreateOptionsList(model.ItemAttributes);
			model.CategoricalAttributes.addEventListener(CollectionEvent.COLLECTION_CHANGE, function(e:Event):void {
				categoricalOptions = CreateOptionsList(model.CategoricalAttributes);
			});
			model.NumericalAttributes.addEventListener(CollectionEvent.COLLECTION_CHANGE, function(e:Event):void {
				numericalOptions = CreateOptionsList(model.NumericalAttributes);
			});
			model.ItemAttributes.addEventListener(CollectionEvent.COLLECTION_CHANGE, function(e:Event):void {
				generalOptions = CreateOptionsList(model.ItemAttributes);
			});
		}
		
		protected function OnChange(event:IndexChangeEvent):void {

			// Based on selected control will set the SortBy, GroupBy or ... of the model and refresh the list view.
			var dd:DropDownList = event.target as DropDownList;
			switch (dd.id) {
				case "SizeByList":
					//Debug.log("ColorByList");
					model.SizeBy = numericalOptions[event.newIndex];
					break;
				case "ColorByList":
					//Debug.log("ColorByList");
					model.ColorBy = categoricalOptions[event.newIndex];
					break;
				case "groupByList":
					//Debug.log("GroupByList");
					model.GroupBy = categoricalOptions[event.newIndex];
					break;
				case "sortByList":
					//Debug.log("SortByList");
					model.SortBy = generalOptions[event.newIndex];
					break;
			}
		}
		
		private function CreateOptionsList(data:ArrayCollection):ArrayCollection
		{
			var source:Array = new Array(1);
			source[0] = null;
			source = source.concat(data.source);
			var options:ArrayCollection = new ArrayCollection(source);
			return options;
		}
	}
}
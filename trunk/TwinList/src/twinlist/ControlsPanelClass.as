package twinlist
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.RadioButtonGroup;
	import spark.components.ToggleButton;
	import spark.events.IndexChangeEvent;
	
	public class ControlsPanelClass extends Group
	{
		public static const SORT_ASCEND:int = 0;
		public static const SORT_DESCEND:int = 1;
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var categoricalOptions:ArrayCollection;
		[Bindable]
		protected var numericalOptions:ArrayCollection;
		[Bindable]
		protected var generalOptions:ArrayCollection;
		[Bindable]
		public var sizeByList:DropDownList;
		[Bindable]
		public var colorByList:DropDownList;
		[Bindable]
		public var groupByList:DropDownList;
		[Bindable]
		public var sortByList:DropDownList;
		[Bindable]
		public var rbgGroupByAscend:RadioButtonGroup;
		[Bindable]
		public var rbgSortByAscend:RadioButtonGroup;
		
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
		
		protected function OnDropDownChange(event:IndexChangeEvent):void
		{
			// Based on selected control will set the SortBy, GroupBy or ... of the model and refresh the list view.
			var dd:DropDownList = event.target as DropDownList;
			switch (dd) {
				case sizeByList:
					model.SizeBy = numericalOptions[event.newIndex];
					break;
				case colorByList:
					model.ColorBy = categoricalOptions[event.newIndex];
					break;
				case groupByList:
					model.GroupBy = categoricalOptions[event.newIndex];
					break;
				case sortByList:
					model.SortBy = generalOptions[event.newIndex];
					break;
			}
		}
		
		protected function OnAscendDescendChange(event:Event):void
		{
			var rbg:RadioButtonGroup = event.target as RadioButtonGroup;
			switch (rbg) {
				case rbgGroupByAscend:
					break;
				case rbgSortByAscend:
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
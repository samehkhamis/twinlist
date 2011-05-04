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
		public static const SORT_ASCEND:Boolean = true;
		public static const SORT_DESCEND:Boolean = false;
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
		[Bindable]
		public var groupByAscend:Group;
		[Bindable]
		public var sortByAscend:Group;
		
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
			model.addEventListener(Model.DATA_LOADED, function(e:Event):void {
				rbgGroupByAscend.selectedValue = SORT_ASCEND;
				rbgSortByAscend.selectedValue = SORT_ASCEND;
				groupByAscend.enabled = false;
				sortByAscend.enabled = false;
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
					model.SetGroupBy(categoricalOptions[event.newIndex], rbgGroupByAscend.selectedValue);
					groupByAscend.enabled = event.newIndex != 0;
					break;
				case sortByList:
					model.SetSortBy(generalOptions[event.newIndex], rbgSortByAscend.selectedValue);
					sortByAscend.enabled = event.newIndex != 0;
					break;
			}
		}
		
		protected function OnAscendDescendChange(event:Event):void
		{
			var rbg:RadioButtonGroup = event.target as RadioButtonGroup;
			switch (rbg) {
				case rbgGroupByAscend:
					model.SetGroupBy(categoricalOptions[groupByList.selectedIndex], rbg.selectedValue);
					break;
				case rbgSortByAscend:
					model.SetSortBy(generalOptions[sortByList.selectedIndex], rbg.selectedValue);
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
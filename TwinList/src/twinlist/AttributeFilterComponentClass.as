package twinlist
{
	import flash.events.Event;
	
	import mx.containers.*;
	import mx.core.*;
	import mx.events.FlexEvent;
	
	import mx.collections.ArrayCollection;


	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	

	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;

	public class AttributeFilterComponentClass extends Group
	{

		[Bindable]
		protected var model:Model = Model.Instance;
	        protected var attributes:ArrayCollection;
	        protected var attrToShow:ArrayCollection;

		private var lb:spark.components.List;
		
		public function AttributeFilterComponentClass(attributes:ArrayCollection)
		{
			super();
			this.attributes = attributes;
			lb = new spark.components.List();
			var layout:VerticalLayout = new VerticalLayout();
			layout.requestedRowCount = 4;
			lb.layout = layout;
			lb.minWidth = 200;
			lb.allowMultipleSelection = true;
			lb.dataProvider = attributes;
			lb.addEventListener(IndexChangeEvent.CHANGE, OnChange);
			addElementAt(lb, 0);
			attrToShow = attributes;
			SelectAll();
		}
		
	        public function SelectAll():void
		{
			var allIdx:Vector.<int> = new Vector.<int>(attributes.length);
			for (var i:int = 0; i < allIdx.length; i++) {
				allIdx[i] = i;
			}
			lb.selectedIndices = allIdx;
			attrToShow = new ArrayCollection(attributes.toArray());
			model.ShownAttributes = attrToShow;
			model.Redraw();
		}
		
		public function ClearAll():void
		{
			lb.selectedIndex = -1;
			attrToShow = new ArrayCollection();
			model.ShownAttributes = attrToShow;
			model.Redraw();
		}
		
		protected function OnChange(event:Event):void
		{
			var values:Array = new Array(lb.selectedItems.length);
			for (var i:int = 0; i < values.length; i++) {
				values[i] = lb.selectedItems[i];
			}
			attrToShow = new ArrayCollection(values);
			model.ShownAttributes = attrToShow;
			model.Redraw();
		}
	}
}
package twinlist {

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.*;
	import mx.core.*;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.Label;
	
	import twinlist.filter.IFilter;
	import twinlist.list.AttributeDescriptor;

	public class FilterComponentClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		protected var attribute:AttributeDescriptor;
		protected var filter:IFilter;
		public var lbl:Label;
		public var cb:CheckBox;
		public var selectAllBtn:Button;
		public var clearAllBtn:Button
		
		public function FilterComponentClass()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);
		}
		
		public function get Attribute():AttributeDescriptor
		{
			return attribute;
		}
		public function set Attribute(attribute:AttributeDescriptor):void
		{
			this.attribute = attribute;
			lbl.text = attribute.toString();
		}
		
		public function get Checked():Boolean {
			return cb.selected;
		}
		public function set Checked(checked:Boolean):void {
			cb.selected = checked;
			EnableFilter(checked);
		}
		
		public function SetAll(selected:Boolean):void
		{
			if (Checked)
				model.FilterListViewerData();
		}
		
		protected function OnChange(event:Event):void
		{
			if (Checked)
				model.FilterListViewerData();
		}
		
		private function OnInitComplete(event:Event):void
		{
			cb.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				EnableFilter(cb.selected);
			});
			selectAllBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				SetAll(true);
			});
			clearAllBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				SetAll(false);
			});
		}

		private function EnableFilter(enabled:Boolean):void
		{
			if (enabled)
				model.AddFilter(filter);
			else {
				model.DelFilter(filter);
			}
		}
	}
}
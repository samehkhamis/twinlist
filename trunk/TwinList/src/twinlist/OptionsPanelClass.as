package twinlist
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.HSlider;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.NumericStepper;
	import spark.components.RadioButtonGroup;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;
	
	import twinlist.list.AttributeDescriptor;
	import twinlist.list.ItemAttribute;
	
	
	public class OptionsPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var datasetOptions:ArrayCollection;
		
		public function OptionsPanelClass()
		{
			super();
			var dataSets:Array = new Array("Cars", "Medication", "SOTU", "Genes (Kidney)");
			datasetOptions = new ArrayCollection(dataSets);
		}
		
		protected function OnFontSizeChange(event:Event):void
		{
			var tgt:NumericStepper = event.target as NumericStepper;
			model.SetOption(new Option(Option.OPT_FONTSIZE, tgt.value));
		}
		
		
		protected function OnAnimSpeedChange(event:Event):void
		{
			var tgt:HSlider = event.target as HSlider;
			var val:Number = Math.pow(2.0, -tgt.value);
			model.SetOption(new Option(Option.OPT_ANIMATIONSPEED, val));
		}
		
		protected function OnLinkIdenticalChange(event:Event):void
		{
			var tgt:CheckBox = event.target as CheckBox;
			model.SetOption(new Option(Option.OPT_LINKIDENTICAL, tgt.selected));
		}
		
		protected function OnLinkSimilarChange(event:Event):void
		{
			var tgt:CheckBox = event.target as CheckBox;
			model.SetOption(new Option(Option.OPT_LINKSIMILAR, tgt.selected));
		}
		
		protected function OnAttribIdenticalChange(event:Event):void
		{
			var tgt:CheckBox = event.target as CheckBox;
			model.SetOption(new Option(Option.OPT_ATTRIDENTICAL, tgt.selected));
		}
		
		protected function OnAfterActionChange(event:Event):void
		{
			var tgt:RadioButtonGroup = event.target as RadioButtonGroup;
			model.SetOption(new Option(Option.OPT_AFTERACTION, tgt.selectedValue as String));
		}
		
		protected function OnDatasetChange(event:IndexChangeEvent):void
		{
			switch (event.newIndex) {
				case 0: model.SetDataset(Model.DATA_CARS); break;
				case 1: model.SetDataset(Model.DATA_MED_REC); break;
				case 2: model.SetDataset(Model.DATA_SOTU); break;
				case 3: model.SetDataset(Model.DATA_GENES_KIDNEY); break;
			}
		}
	}
}
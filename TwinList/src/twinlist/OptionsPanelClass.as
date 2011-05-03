package twinlist
{
	import flash.events.Event;
	
	import mx.controls.HSlider;
	
	import spark.components.CheckBox;
	import spark.components.Group;
	import spark.components.NumericStepper;
	import spark.components.RadioButtonGroup;

	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import spark.components.DropDownList;
	import spark.events.IndexChangeEvent;
	
	public class OptionsPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		
	        [Bindable]
	  protected var datasetOptions:ArrayCollection;
		public function OptionsPanelClass()
		{
			super();
			var dataSets:Array = new Array("Cars", "Medication", "SOTU");
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
			}
		}
	}
}
package twinlist
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.HSlider;

	import spark.components.Button;
        import spark.components.CheckBox;
        import spark.components.Group;
        import spark.components.NumericStepper;
        import spark.components.RadioButtonGroup;


	import twinlist.list.AttributeDescriptor;
	import twinlist.list.ItemAttribute;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;
	
	
	public class OptionsPanelClass extends Group
	{
		[Bindable]
		protected var model:Model = Model.Instance;
		[Bindable]
		protected var datasetOptions:ArrayCollection;
	        [Bindable]
	        public var shownItemsGroup:Object;
	        private var shownItemComponent:AttributeFilterComponentClass;
		public var selectAllAttribBtn:Button;
		public var clearAllAttribBtn:Button

		public function OptionsPanelClass()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE,OnInitComplete);
			addEventListener(Model.DATA_LOADED, function(e:Event):void {
			    GenerateShownItems();
			  }); 
			var dataSets:Array = new Array("Cars", "Medication", "SOTU", "Genes (Kidney)");
			datasetOptions = new ArrayCollection(dataSets);
		}
		
	        private function GenerateShownItems():void
	        {
		  if(shownItemComponent != null){
		    shownItemsGroup.removeAllElements();
		  }
		  shownItemComponent = new AttributeFilterComponentClass(model.AllAttributes);
		  shownItemsGroup.addElement(shownItemComponent);
		}

		private function OnInitComplete(event:Event):void
		{
		  removeEventListener(FlexEvent.CREATION_COMPLETE, OnInitComplete);
		  GenerateShownItems();
		  selectAllAttribBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
		      shownItemComponent.SelectAll();
		    });
		  clearAllAttribBtn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
		      shownItemComponent.ClearAll();
		    });

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

		protected function OnAttribIdenticalChange(event:Event):void
		{
			var tgt:CheckBox = event.target as CheckBox;
			model.SetOption(new Option(Option.OPT_ATTRIBIDENTICAL, tgt.selected));
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
package twinlist.filter
{
	import twinlist.ListItem;
	
	public interface IFilter
	{
		function Apply(item:ListItem):Boolean;
		
		function get AttributeName():String;
	}
}
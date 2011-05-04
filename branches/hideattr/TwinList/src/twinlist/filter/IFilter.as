package twinlist.filter
{
	import twinlist.list.ListItem;
	
	public interface IFilter
	{
		function Apply(item:ListItem):Boolean;
		
		function get AttributeName():String;
	}
}
package gui_window::r_plot::selected_netgraph;
use base qw(gui_window::r_plot);

sub option1_options{
	return [
		'�濴�����޲��',
		'�濴���ʼ�����',
		'���֥���ո��С��޲��',
		'���֥���ո��С�modularity��',
		'�ʤ�',
	];
}

sub option1_name{
	return ' ���顼��';
}

sub win_title{
	return '��Ϣ�졦�����ͥåȥ��';
}

sub win_name{
	return 'w_selected_netgraph_plot';
}


sub base_name{
	return 'selected_netgraph';
}

1;